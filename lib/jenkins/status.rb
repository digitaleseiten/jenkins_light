module Jenkins

  class Status
    attr_reader :current, :previous

    def initialize(build_name)
      @previous = "unknown"
      @current = "unknown"
      @build_name = build_name
    end

    def update(xml)
      @previous = @current
      @current  = from_xml(xml)
    end

    private

    # returns a string "(stable)" or "(failed)" or "(?)" or ""
    def from_xml(xml)
      parsed_status = "unknown"
      jenkins_status = Hash.new

      if xml
        xml.elements.each("feed/entry/title") do |entry|
          matchdata = entry.text.match(/^(.*) #[0-9]+ (\(.+\))/)
          raise "Failed to match build data #{entry.text}" if matchdata.nil? or matchdata.length != 3

          jenkins_status[matchdata[1]] = matchdata[2]
        end
      end

      build_status = []

      @build_name.each do |build|
        status = jenkins_status[build] || "unknown"
        build_status << [build, status]
      end

      build_status.sort_by! {|status| to_precedence status[1]}

      parsed_status = build_status[0][1] if build_status.length > 0

      overall_status = to_status parsed_status

      print " <#{overall_status}: " + build_status.map{|status| "#{status[0]}=#{to_status(status[1])}"}.join(", ") + "> "

      overall_status
    end

    def to_status(jenkins_status)
      case jenkins_status
        when "(stable)"
          "stable"
        when "(back to normal)"
          "stable"
        when "(?)"
          "building"
        when "(aborted)"
          "aborted"
        when /broken/
          "broken"
        when "unknown"
          "unknown"
        else
          "failed"
        end
    end

    def to_precedence(jenkins_status)
      case jenkins_status
        when "(stable)"
          100
        when "(back to normal)"
          80
        when "(?)"
          40
        when "(aborted)"
          50
        when /broken/
          10
        when "unknown"
          0
        else
          20
        end
    end

  end

end
