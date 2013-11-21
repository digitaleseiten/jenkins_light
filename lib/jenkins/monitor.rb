module Jenkins

  class Monitor < ::Monitor
    load_credentials :jenkins

    attr_reader :status, :activity

    def initialize(default_poll_interval)
      @username     = credential_for :username
      @password     = credential_for :password
      @host          = credential_for :host
      @port         = (credential_for :port || "80").to_i
      @path         = (credential_for :path || "/")
      @build_name   = credential_for :build_name

      @http         = Net::HTTP.new(@host, @port)
      @http.use_ssl = true if @port == 443

      @status       = Status.new(@build_name)
      @activity     = Activity.new(@build_name, @status)
      @timer        = Timer.new(1.0) { @activity.update }

      super(default_poll_interval)
    end

    # this gets called from the super class through a timer every 10 seconds
    def poll_now
      @timer.start(@default_poll_interval)

      Thread.new do
        @http.start() do |http|
          begin
            request = Net::HTTP::Get.new("#{@path}rssLatest")
            request.basic_auth @username, @password
            response = http.request(request)

            # Raises an HTTP error if the response is not 2xx (success).
            response.value

            @status.update(REXML::Document.new response.body)
            @activity.update(@status.previous, @status.current)

          rescue => e
            puts "Unable to poll #{http.inspect}: #{e.inspect}"
            puts e.backtrace

          end
        end
      end
    end

  end

end
