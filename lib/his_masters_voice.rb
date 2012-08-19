###########################################################################
#
# This represent what the user wants - messages an be sent from any number
# users and inputs at any time.
#
# This is a singleton class to make sure that the software only listens
# to one user and one source at a time.
#
###########################################################################

class HisMastersVoice
  include Singleton

  @@last_said = "what are you doing" # default last message from the user

  WORDS_MEANS_ACTION = {
    "whats up"           => { :status => {} },
    "how are you"        => { :manual_blink => {:number_of_times => 10, :interval => 0.1, :wait_after_blink => 10.0 } },
    "shut up"            => { :turn_off => {}},
    "red light"          => { :red => {}},
    "green light"        => { :green => {}},
    "blue light"         => { :blue => {}},
    "orange light"       => { :orange => {}},
    "turn off"           => { :turn_off => {}},
    "turn on"            => { :turn_on  => {}},
  }

  def help
    "Here are the things you can talk to me about. Just send me a mail with what want in the subject line:\n\n" +
    WORDS_MEANS_ACTION.keys.join("\n")
  end

  def said_this(message)
    puts "His Master said: #{message}"
    @@last_said = message
  end

  def means_anything?(message)
    !meaning(message).empty?
  end

  # this send the instance calling this methid and action
  # depending on what last message that came in form the user
  # that is defined in the WORDS_MEANS_ACTION hash
  def tell_me(who_wants_to_know)
    action_and_options = meaning(@@last_said).pop
    action  = action_and_options.keys.first
    options = action_and_options.values.first

    who_wants_to_know.send action, options
  end

  private

  # returns empty array or words and action that match the message
  def meaning(message)
    WORDS_MEANS_ACTION.find {|words, action| words.match(Regexp.new(message))} || []
  end


end


