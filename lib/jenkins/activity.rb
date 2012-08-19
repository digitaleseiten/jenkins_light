module Jenkins

  class Activity
    attr_reader :last_build_duration

    def initialize(build_name, status)
      @build_name = build_name
      @status     = status
      @start_build_time = 0.0
      @_current_build_time = 0.0
    end

    def current_build_time
      update(@previous_state, @current_state)
      @_current_build_time
    end

    def build_started_from_beginning?
      @_build_started_from_beginning
    end

    def update(previous_state, current_state)
      @previous_state = previous_state
      @current_state = current_state

      case previous_state + " -> " + current_state
      when "unknown -> building"
        software_started_during_build
      when "stable -> building"
        build_started_from_beginning
      when "aborted -> building"
        build_started_from_beginning
      when "broken -> building"
        build_started_from_beginning
      when "building -> aborted"
        build_aborted
      when "building -> stable"
        build_finished
      when "building -> building"
        build_in_progress
      end
    end

    private

    def build_in_progress
      @_current_build_time = Time.now.to_f - @start_build_time
    end

    def build_aborted; end

    def software_started_during_build
      @_build_started_from_beginning = false
    end

    def build_started_from_beginning
      @_build_started_from_beginning = true
      @start_build_time              = Time.now.to_f
      @last_build_duration           = read_last_build_duration
    end

    def build_finished
      write_last_build_duration if build_started_from_beginning? && @status.current != "broken" && @status.current != "aborted"
    end

    def write_last_build_duration
      last_build_duration = Time.now.to_f - @start_build_time
      last_build_duration = 0 if last_build_duration < 0
      File.open(PROJECT_ROOT + "/data/#{@build_name}.txt", 'w+') {|file_handle| file_handle.write(last_build_duration.to_s) }
    end

    def read_last_build_duration
      first_line = nil
      File.open(PROJECT_ROOT + "/data/#{@build_name}.txt", "r") {|file_handle| first_line = file_handle.readline} rescue nil
      first_line.to_f
    end

  end

end