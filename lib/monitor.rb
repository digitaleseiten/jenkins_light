class Monitor
  # This is the interval between polling jenkins and github
  DEFAULT_POLL_INTERVAL = 10 # every 10 seconds

  def initialize
    @timer = Timer.new(DEFAULT_POLL_INTERVAL) { self.poll_now }
    @timer.start
  end

end