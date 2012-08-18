module Github

  class Monitor < ::Monitor
    CREDENTAILS = YAML::load( File.open(  File.expand_path(File.dirname(__FILE__) + '../../../config/github_credentials.yml') ) )["setup"]

    def initialize
      @username         = CREDENTAILS["username"]
      @password         = CREDENTAILS["password"]
      @repository_owner = CREDENTAILS["repository_owner"]
      @repository_name  = CREDENTAILS["repository_name"]

      super
    end

    def poll_now
      @timer.start

      Thread.new do
        @pull_requests = github.pull_requests.list @repository_owner, @repository_name, :mime_type => :full
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
