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
geary -s localhost:4731
```

Processing jobs from multiple servers is a matter of passing in comma-delimited addresses:

```
geary -s localhost:4730,localhost:4731
```
