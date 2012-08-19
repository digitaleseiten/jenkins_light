module Gmail

  class Monitor < ::Monitor
    CREDENTAILS = YAML::load( File.open(  File.expand_path(File.dirname(__FILE__) + '../../../config/gmail_credentials.yml') ) )["setup"]

    def initialize(default_poll_interval)
      @feature_enabled = CREDENTAILS["feature_enabled"]
      super(default_poll_interval)
    end

    def poll_now
      @timer.start
      poll_mail if @feature_enabled
    end

    private

    def poll_mail
      Thread.new do
        mail.all.each do |mail|
          his_words_now = mail.subject

          HisMastersVoice.instance.now_wants_me_to('shut up') if HisMastersVoice.instance.previously_wanted_me_to('wake up') && his_words_now.match(/shut up/)
          HisMastersVoice.instance.now_wants_me_to('wake up') if HisMastersVoice.instance.previously_wanted_me_to('shut up') && his_words_now.match(/wake up/)
        end
      end
    end

    def mail
      @mail ||= setup_mail_defaults
    end


    def setup_mail_defaults
      if @feature_enabled
        Mail.defaults do
          retriever_method :pop3, :address    => CREDENTAILS["pop_url"],
                                  :port       => CREDENTAILS["pop_port"].to_i,
                                  :user_name  => CREDENTAILS["username"],
                                  :password   => CREDENTAILS["password"],
                                  :enable_ssl => true
        end
      end
      Mail
    end

  end

end