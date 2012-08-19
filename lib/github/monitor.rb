module Github

  class Monitor < ::Monitor
    CREDENTAILS = YAML::load( File.open(  File.expand_path(File.dirname(__FILE__) + '../../../config/github_credentials.yml') ) )["setup"]

    def initialize(default_poll_interval)
      @feature_enabled  = CREDENTAILS["feature_enabled"]
      @username         = CREDENTAILS["username"]
      @password         = CREDENTAILS["password"]
      @repository_owner = CREDENTAILS["repository_owner"]
      @repository_name  = CREDENTAILS["repository_name"]

      super(default_poll_interval)
    end

    def poll_now
      puts "<poll github>"
      @timer.start(@default_poll_interval)
      if @feature_enabled
        Thread.new do
          @pull_requests = github.pull_requests.list @repository_owner, @repository_name, :mime_type => :full
        end
      end
    end

    def pull_requests?
      !(@pull_requests || []).empty?
    end

    private

    def github
      @gh ||= Github.new basic_auth: "#{@username}:#{@password}"
    end

  end

end
