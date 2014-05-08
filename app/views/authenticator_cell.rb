class AuthenticatorCell < UITableViewCell
  extend IB

  DEFAULT_HEIGHT = 88

  attr_accessor :authenticator

  outlet :token_label, UILabel
  outlet :serial_label, UILabel
  outlet :countdown_view, UIProgressView

  def prepareForReuse
    super
  end
end
