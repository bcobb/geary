# Geary

Geary gives Gearman job processing a familiar face.

## Getting Started

1. Add Geary to your Gemfile:

  ```ruby
  gem 'geary', require: false
  ```

2. Create a worker:

  ```ruby
    require 'geary/worker'

    class FollowUpWorker
      extend Geary::Worker

      def perform(id)
        # User.find(id).tap do |user|
        #   FollowUpMailer.follow_up_with(user)
        # end
      end

    end
  ```

3. Start working:

  ```
  geary
  ```

4. Send jobs to the workers:

  ```ruby
  FollowUpWorker.perform_async(1)
  ```

## Configuring Geary

Without configuration, Geary will spawn 25 workers, each of which will process jobs from a Gearman server running on `localhost:4730`. Geary can be configured to process jobs from a different Gearman server, as well as from multiple servers. For instance, if you're running a Gearman server on a different address, you might start the workers like this:

```
geary -s gearman://localhost:4731
```

Processing jobs from multiple servers is a matter of passing in comma-delimited addresses:

```
geary -s gearman://localhost:4730,gearman://localhost:4731
```

Classes which extend themselves with `Geary::Worker` submit background jobs to a Gearman server running on `localhost:4730` by default, but can be configured to submit jobs to multiple servers like so:

```ruby
require 'geary/worker'

class OverheadWorker
  extend Geary::Worker

  use_gearman_client 'gearman://localhost:4730', 'gearman://localhost:4731'

  def perform ; end
end
```

The following code will submit four jobs.

```ruby
4.times { OverheadWorker.perform_async }
```

If the server listening on port 4730 disappears midway, our gearman client will disconnect from it, and submit future jobs to the server listening on 4731. As of right now, there is no backoff behavior. If the server listening on 4731 disappears and we're still not out of jobs to submit, we'll attempt to reconnect to `localhost:4730`, potentially to our never-ending dismay.
