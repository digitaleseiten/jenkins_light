module Gmail

  class Monitor < ::Monitor
    load_credentials :gmail

    def initialize(default_poll_interval)
      @feature_enabled = credential_for :feature_enabled
      @pop3_address    = credential_for :pop3_address
      @pop3_username   = credential_for :pop3_username
      @pop3_password   = credential_for :pop3_password
      @pop3_enable_ssl = credential_for :pop3_enable_ssl
      @pop3_port       = (credential_for :pop3_port,      @feature_enabled).to_i

      super(default_poll_interval)
    end

    def poll_now
      @timer.start(@default_poll_interval)
      poll_mail
    end

    private

    def poll_mail
      return unless @feature_enabled
      puts "<poll mail>"

      Thread.new do
        mail.all.each do |email|
          unless HisMastersVoice.instance.means_anything?(email.subject)
            respond_with_message_has_no_meaning(email.from)
          else
            HisMastersVoice.instance.said_this(email.subject)
          end
        end
      end
    end

    def respond_with_message_has_no_meaning(this_address)
      puts "responding with WTF to #{this_address.inspect}"
      return # TODO do this in the next update
      me = @pop3_username

      email = mail.deliver do
        from    me
        to      this_address
        subject 'WTF are you talking about kid?'
        body    HisMastersVoice.instance.help
      end
    end

    def mail
      @mail ||= setup_mail_defaults
    end

    def setup_mail_defaults
      # for some reason the retriever_method does not get the instance vars set in the hash directly
      # this is why they are copied into local vars here
      address    = @pop3_address
      port       = @pop3_port
      user_name  = @pop3_username
      password   = @pop3_password
      enable_ssl = @pop3_enable_ssl

      Mail.defaults do
        retriever_method :pop3, :address    => address,
                                :port       => port,
                                :user_name  => user_name,
                                :password   => password,
                                :enable_ssl => enable_ssl
      end
      Mail
    end

  end

end