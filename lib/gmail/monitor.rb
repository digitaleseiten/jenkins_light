module Gmail

  class Monitor < ::Monitor
    load_credentials :gmail

    def initialize(default_poll_interval)
      @feature_enabled = credential_for :feature_enabled
      @pop3_address    = credential_for :pop3_address,    @feature_enabled
      @pop3_username   = credential_for :pop3_username,   @feature_enabled
      @pop3_password   = credential_for :pop3_password,   @feature_enabled
      @pop3_enable_ssl = credential_for :pop3_enable_ssl, @feature_enabled
#      @reciever_filter = credential_for :reciever_filter, false
      @pop3_port       = (credential_for :pop3_port,      @feature_enabled).to_i

      super(default_poll_interval)
    end

    def poll_now
      @timer.start(@default_poll_interval)
      poll_mail if @feature_enabled
    end

    private

    def poll_mail
      puts "<poll mail>"
      puts @feature_enabled.inspect
      puts @pop3_address.inspect
      puts @pop3_username.inspect
      puts @pop3_password.inspect
      puts @pop3_enable_ssl.inspect
      puts @pop3_port.inspect

#      Thread.new do
        begin
          mail.all.each do |mail|
            puts "got mail"
#            puts @reciever_filter.inspect
#            if @reciever_filter
#              read_mail = mail.envelope.from.match(Regexp.new(@reciever_filter))
#            else
#              read_mail = true
#            end
#            puts "read mail: #{read_mail}"
#            if read_mail
#              if !(understood = HisMastersVoice.instance.said_this(mail.subject))
#                respond_with_message_has_no_meaning(mail.envelope.from)
#              end
#            end
          end
          rescue => error
            puts error.message
          end
#      end
    end


    def respond_with_message_has_no_meaning(sender)
      mail = mail.new do
        from    @pop3_username
        to      sender
        subject 'WTF are you talking about kid?'
        body    HisMastersVoice.instance.help
      end
    end

    def mail
      @mail ||= setup_mail_defaults
    end

    def setup_mail_defaults
      if @feature_enabled
        Mail.defaults do
          retriever_method :pop3, :address    => @pop3_address,
                                  :port       => @pop3_port,
                                  :user_name  => @pop3_username,
                                  :password   => @pop3_password,
                                  :enable_ssl => @pop3_enable_ssl
        end
      end
      Mail
    end

  end

end