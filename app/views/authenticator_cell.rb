class AuthenticatorCell < UITableViewCell
  DEFAULT_HEIGHT = 88

  attr_accessor :authenticator

  def prepareForReuse
    super
  end
end
