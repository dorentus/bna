class AuthenticatorCell < UITableViewCell
  include TokenDisplay

  outlet :serial_label, UILabel

  DEFAULT_HEIGHT = 88

  def authenticator=(a_authenticator)
    @authenticator = a_authenticator
    serial_label.text = authenticator.serial
    update_token
  end
end
