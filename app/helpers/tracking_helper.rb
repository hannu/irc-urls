module TrackingHelper
  def button_text(publicity)
    if (publicity == 'public' || publicity == 'private')
      text = "make " + publicity
    else
      text = "stop tracking"
    end
    return text
  end
end
