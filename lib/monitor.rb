class Monitor
  # This is the interval between polling jenkins and github

  def initialize(default_poll_interval)
    @default_poll_interval = default_poll_interval
    @timer = Timer.new(0) { self.poll_now }
    @timer.start
  end

end