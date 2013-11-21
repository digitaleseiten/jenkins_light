class Manager
  extend Forwardable
  # degate methods for commands comming from the user
  def_delegators :@light_controller, :red, :green, :blue, :orange, :turn_off, :turn_on, :manual_blink

  GITHUB_DEFAULT_POLL_INTERVAL = 10 # every 10 seconds
  JENKINS_DEFAULT_POLL_INTERVAL = 10 # every 10 seconds
  GMAIL_DEFAULT_POLL_INTERVAL = 60 # every 60 seconds

  STATUS_LIGHT_MAPPING = {
    "aborted"  => "turn_off",
    "stable"   => "green",
    "building" => "blue",
    "failed"   => "red",
    "broken"   => "red",
    "unknown"  => "orange" }

  # must be a float otherwise its not possible to have blink times under 1 second
  DEFAULT_BLINK_INTERVAL = 2.0

  def initialize
    @light_controller = Light::Controller.new(DEFAULT_BLINK_INTERVAL)
    @jenkins_monitor  = Jenkins::Monitor.new(JENKINS_DEFAULT_POLL_INTERVAL)
    @github_monitor   = Github::Monitor.new(GITHUB_DEFAULT_POLL_INTERVAL)
    @gmail_monitor    = Gmail::Monitor.new(GMAIL_DEFAULT_POLL_INTERVAL)
  end

  #find out what the user wants us to do
  #his masters voice will call the methods based on what the user last told us
  def light_the_way
    HisMastersVoice.instance.tell_me(self)
  end

  # This is the normal mode of operation,
  # check out what jenkins is doing,
  # check for any pzll requests in git hub
  # see if we got mail with new instructions
  # and put the right colors on the light and blink it if required
  def status(options={})
    # get a snap shot of the jenkins here as we dont want it to change while we are working things out
    jenkins_status = @jenkins_monitor.status.current
    # set the light color, if we dont have a color for the status then turn the light off
    @light_controller.send(STATUS_LIGHT_MAPPING[jenkins_status] || "do_nothing")
    # set the blink interval
    @light_controller.blink_interval = current_blink_interval
    # make it blink if jenkins is building or broken, or there is a pull request pending
    @light_controller.blink_please = (@jenkins_monitor.blink_while_building && jenkins_status == "building") || jenkins_status == "broken" || (jenkins_status == "stable" && @github_monitor.pull_requests?)
    # do nothing for 10 miliseconds
    # if we dont do this, the the software will grap all the cpu capacity it can get
    # just to go round in a loop which mostly does nothing.
    sleep 0.1
  end

  private

  def current_blink_interval
    # build_started_from_beginning? is only true if a build is progress that started from the beginning
    # if thats the case then we need to change the blink rate depending on the progress
    # other wise just take the default blink rate
    @jenkins_monitor.activity.build_started_from_beginning? ? calculate_blink_interval : DEFAULT_BLINK_INTERVAL
  end

  def calculate_blink_interval
    progress_percentage = (@jenkins_monitor.activity.current_build_time / @jenkins_monitor.activity.last_build_duration)
    DEFAULT_BLINK_INTERVAL - (DEFAULT_BLINK_INTERVAL * progress_percentage)
  end

end

