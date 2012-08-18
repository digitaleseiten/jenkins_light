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
      @power           = 1 # default send power to the light for the blinker
      @blink_timer     = Timer.new(default_blink_interval) { blink }
      @blink_timer.start
    end

    def blink
      @blink_timer.start(@_blink_interval)
      if @blink_please
        (@power ^= 1) == 1 ? turn_on : turn_off
      end
    end

    def blink_interval=(interval)
      # no blinking faster than 10ms please
      @_blink_interval = interval < 0.01 ? 0 : interval
    end

    def green;    light GREEN;  end
    def blue;     light BLUE;   end
    def red;      light RED;    end
    def orange;   light ORANGE; end

    def do_nothing; end

    def turn_on
      color_key = @current_color || ORANGE
      send_data("\x65\x0C#{color_key}\xFF\x00\x00\x00\x00")
    end

    def turn_off
      send_data("\x65\x0C#{OFF}\xFF\x00\x00\x00\x00")
    end

    private

    # only send data to the light when the color should change
    def light(color_key)
      if color_key && color_key != @current_color
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
        puts "device not found"
      end
    end

    def device
      @device ||= USB.devices.find {|device| device.idVendor == VENDOR_ID && device.idProduct == PRODUCT_ID }
    end

  end
end