module Jenkins

  class Monitor < ::Monitor
    attr_reader :status, :activity
    CREDENTAILS = YAML::load( File.open(  File.expand_path(File.dirname(__FILE__) + '../../../config/jenkins_credentials.yml') ) )["setup"]

    def initialize
      @username     = CREDENTAILS["username"]
      @password     = CREDENTAILS["password"]
      @url          = CREDENTAILS["url"]
      @build_name   = CREDENTAILS["build_name"]
      @port         = (CREDENTAILS["port"] || "80").to_i

      @http         = Net::HTTP.new(@url, @port)
      @http.use_ssl = true if @port == 443

      @status       = Status.new(@build_name)
      @activity     = Activity.new(@build_name, @status)
      @timer        = Timer.new(1.0) { @activity.update }

      super
    end

    # this gets called from the super class through a timer every 10 seconds
    def poll_now
      @timer.start

      Thread.new do
        @http.start() do |http|
          request = Net::HTTP::Get.new('/rssLatest')
          request.basic_auth @username, @password
          response = http.request(request)
          @status.update(REXML::Document.new response.body)
          @activity.update(@status.previous, @status.current)
        end
      end
    end

  end

end
