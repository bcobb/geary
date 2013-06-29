# Geary

Geary gives Gearman job processing a familiar face.

```ruby
# in app/workers/hard_worker.rb
class HardWorker
  extend Geary::Worker

  def perform(some, arguments)
    # use those arguments to do something great
  end
end

# in your application
HardWorker.perform_async('some', 'argument')
HardWorker.perform_in(1.day, 'some', 'argument')
```
