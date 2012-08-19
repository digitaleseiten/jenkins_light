module Github

  class Monitor < ::Monitor
    load_credentials :github

    def initialize(default_poll_interval)
      @feature_enabled  = credential_for :feature_enabled
      @username         = credential_for :username,         @feature_enabled
      @password         = credential_for :password,         @feature_enabled
      @repository_owner = credential_for :repository_owner, @feature_enabled
      @repository_name  = credential_for :repository_name,  @feature_enabled

      super(default_poll_interval)
    end

    def poll_now
      @timer.start(@default_poll_interval)

      print " <#{(@pull_requests || []).length} pull request(s)> "

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
