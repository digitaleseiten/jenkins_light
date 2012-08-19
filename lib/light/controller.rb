module Light

  class Controller
    attr_accessor :blink_please

    DELCOM_TRANSMISSION_DATA = { :bmRequestType => 0x21, :bRequest => 0x09, :wValue => 0x0635, :wIndex => 0x0000 }

    VENDOR_ID  = 0x0fc5
    PRODUCT_ID = 0xb080

    GREEN  = "\x01"
    RED    = "\x02"
    BLUE   = "\x04"
    ORANGE = "\x03"
    OFF    = "\x00"

    def initialize(default_blink_interval)
      @blink_power        = true # default send power to the light for the blinker
      @blink_timer        = Timer.new(default_blink_interval) { timer_blink }
      @blink_timer.start
    end

    def manual_blink(user_options = {:number_of_times => 2, :interval => 1.0, :wait_after_blink => 0 })
      user_options[:number_of_times].times {|count|
        turn_off
        sleep user_options[:interval]
        turn_on
        sleep user_options[:interval]
        }
      sleep user_options[:wait_after_blink]
    end

    def timer_blink
      @blink_timer.start(@_blink_interval)
      if @blink_please
        (@blink_power ^= true)  ? turn_on : turn_off
      end
    end

    def blink_interval=(interval)
      # no blinking faster than 10ms please
      @_blink_interval = (interval < 0.01) ? 0 : interval
    end

    # The methods that accept user_options can be used directly
    # by the user for instance through an email message
    def green(user_options={});    light GREEN;  end
    def blue(user_options={});     light BLUE;   end
    def red(user_options={});      light RED;    end
    def orange(user_options={});   light ORANGE; end
    def do_nothing(user_options={}); end

    def turn_on(user_options={})
      if !@power_on
        @power_on = true
        print "light on"
        color_key = @current_color || ORANGE
        send_data("\x65\x0C#{color_key}\xFF\x00\x00\x00\x00")
      end
    end

    def turn_off(user_options={})
      if @power_on
        print "light off"
        @power_on = false
        send_data("\x65\x0C#{OFF}\xFF\x00\x00\x00\x00")
      end
    end

    private

    # only send data to the light when the color should change
    def light(color_key)
      if color_key && color_key != @current_color
        print " <light: #{color_key.inspect}> "
        @current_color = color_key
        send_data("\x65\x0C#{color_key}\xFF\x00\x00\x00\x00")
      end
    end

    def send_data(dataOut)
      if device
        begin
          transmit_data = DELCOM_TRANSMISSION_DATA.merge(:dataOut => dataOut, :timeout => 1000)
          device.open {|device_handle| usb_control_msg(transmit_data[:bmRequestType], transmit_data[:bRequest], transmit_data[:wValue], transmit_data[:wIndex], transmit_data[:dataOut], transmit_data[:timeout]) }
        rescue => error.message
          puts error.message
        end
      else
        print " <device not found> "
      end
    end

    def device
      @device ||= USB.devices.find {|device| device.idVendor == VENDOR_ID && device.idProduct == PRODUCT_ID }
    end

  end
end