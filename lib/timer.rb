######################################################################
#
# Very simple timer class based a little on how the IOS timers work.
# i.e the main program runs in a loop and call Timer.tick which in turn
# calls tick on all instances of created timers.
#
# When the timers runs down then the timer owner is called back with
# the proc they registered with the timer.
# The proc can then restart the timer with timer.start
#
# obvioulsy the timers are only as acurate as the maximum time it
# takes for the main program loop to complete.
#
######################################################################

class Timer
  attr_accessor :duration

  @@timers = []

  def initialize(duration, &block)
    @timer_running  = false
    @duration       = duration
    @block          = block

    @@timers << self
  end

  def self.tick
    @@timers.each { |timer| timer.tick }
  end

  def start(duration = nil)
    @duration = duration || @duration
    @timer_running = true
    @start_time = Time.now.to_f
  end

  def tick
    if @timer_running
      stop if ready_to_stop?
    end
  end

  def ready_to_stop?
    (Time.now.to_f - @start_time) >= @duration
  end

  def stop
    @timer_running = false
    @block.call
  end

end
