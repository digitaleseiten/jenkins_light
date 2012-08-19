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


