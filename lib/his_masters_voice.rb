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

  def said
    @action
  end

  def said?(action)
    @action == action
  end

  def now_wants_me_to(action)
    @action = action
  end

  def previously_wanted_me_to(action)
    @action == action
  end

end


