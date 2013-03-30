# Geary

Geary gives Gearman job processing a familiar face.

```ruby
# in config/initializers/workers.rb
unless defined? ApplicationWorker
  ApplicationWorker = Geary::Worker.new('localhost:4730')
end

# in app/workers/hard_worker.rb
class HardWorker
  include Skills

  def perform(some, arguments)
    # use those arguments to do something great
  end
end

# in your application
HardWorker.perform_async('some', 'argument')
```
