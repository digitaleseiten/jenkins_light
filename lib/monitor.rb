class Monitor
  @@credentials = {}

  def self.load_credentials(type)
    begin
      @@credentials.merge!(type.to_sym => YAML::load( File.open(  File.expand_path(File.dirname(__FILE__) + "../../config/#{type}_credentials.yml") ) )["setup"])
    rescue => error
      puts error.message
      puts "please check that your #{type}_credentials.yml file is in the config folder"
    end
  end

  def initialize(default_poll_interval)
    @default_poll_interval = default_poll_interval
    @timer = Timer.new(0) { self.poll_now }
    @timer.start
  end

  def credential_for(attribute, compulsory=true)
    owner = self.class.name.downcase.split("::").first
    @@credentials[owner.to_sym]["#{attribute}"] || (compulsory ? (raise "#{type} missing please check your #{self.class.name.downcase}_credentials.yml file") : nil)
  end

end