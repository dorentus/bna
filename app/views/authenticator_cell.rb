class AuthenticatorCell < UITableViewCell
  class SelectionBackgroundView < UIView; end

  include TokenDisplay

  outlet :serial_label, UILabel

  DEFAULT_HEIGHT = 88

  def awakeFromNib
    super
    self.selectedBackgroundView = SelectionBackgroundView.alloc.init
  end

  def authenticator=(a_authenticator)
    @authenticator = a_authenticator
    serial_label.text = authenticator.serial
    update_token
  end
end
