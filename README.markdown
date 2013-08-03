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

For each server [expand] Geary manages a worker pool of N workers, where N is the concurrency level [expand]. Each worker is a Celluloid Actor, connected directly to the Gearman server. By default, when the pool starts, each worker sends "CAN_DO" followed by "PRE_SLEEP" and then waits on a "NOOP" from the server to do work. When a worker finishes a job, it sends "WORK_COMPLETE", "PRE_SLEEP", and waits again on a "NOOP".

Workers can be configured to be aggressive in that instead of sending "PRE_SLEEP" first, they'll send "GRAB_JOB" and only send "NOOP" if they get a "NO_JOB" in response to "GRAB_JOB".

In the first version, Geary will automatically send WORK_COMPLETE when a job finishes, and will not expose a client for the worker to send other messages (e.g. WORK_STATUS). In future versions, it might.

NOTE: an alternative design might be to have one worker connected to all Gearman servers, since a worker is not required to complete jobs before requesting new jobs. This sounds like a tangled ball of global mutable state, so I am not going to attempt to implement such a thing at this time.
