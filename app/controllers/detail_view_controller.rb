class DetailViewController < UIViewController
  extend IB
  include BnaDisplayLinkExt

  outlet :token_label, UILabel
  outlet :restorecode_label, UILabel
  outlet :countdown_view, UIProgressView

  attr_accessor :authenticator

  def viewDidLoad
    super

    self.title = authenticator.serial
    restorecode_label.text = authenticator.restorecode
    update_token
  end

  def update_token
  end

  def update_display_link_timer
    update_token
  end

  def update_token
    return if authenticator.nil?

    timestamp = Time.now.to_f
    token, next_timestamp = authenticator.get_token(timestamp.to_i)
    progress = 1.0 - (next_timestamp - timestamp) / 30.0

    token_label.text = token

    token_label.textColor = BnaHelpers.color_at_progress(progress)
    countdown_view.progress = progress
    countdown_view.progressTintColor = BnaHelpers.color_at_progress(progress)
  end
end
