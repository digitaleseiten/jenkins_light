class Monitor
  # This is the interval between polling jenkins and github

  def initialize(default_poll_interval)
    @timer = Timer.new(default_poll_interval) { self.poll_now }
    @timer.start
  end

end