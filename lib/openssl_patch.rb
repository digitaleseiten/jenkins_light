#############################################
#
# OPENSSL patch because jenkins runs on https
# or should so at least. Some ruby installations
# cannot find thier cert.pem, so the easiest
# way to fix this is just add it into the
# this project
#
#############################################

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=

    def use_ssl=(flag)
      self.ca_file = File.expand_path(File.dirname(__FILE__) + '/ca-bundle.crt')
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end