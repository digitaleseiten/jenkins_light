module Jenkins

  class Status
    attr_reader :current, :previous

    def initialize(build_name)
      @previous = "unknown"
      @build_name = build_name
    end

    def update(xml)
      @previous = @current
      @current  = from_xml(xml)
      print " <#{@current}> "
    end

    private

    # returns a string "(stable)" or "(failed)" or "(?)" or ""
    def from_xml(xml)
      parsed_status = "unknown"

      if xml
        build_names = []
        xml.elements.each("feed/entry/title") {|entry| build_names << entry.text}

        build_master = build_names.find {|build_name| build_name.include?(@build_name) }
        parsed_status = build_master.match(/\(.+\)/).to_s
      end

      case parsed_status
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

  end

end