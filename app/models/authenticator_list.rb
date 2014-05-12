class AuthenticatorList
  KEYCHAIN_SERVICE = 'bna_authenticators'

  class << self
    def number_of_authenticators
      authenticator_serials.count
    end

    def authenticator_at_index(index)
      serial = authenticator_serials[index]
      secret = SSKeychain.passwordForService(KEYCHAIN_SERVICE, account: serial)
      Bnet::Authenticator.new(serial, secret)
    end

    def add_authenticator(authenticator)
      return false if authenticator_exists? authenticator
      SSKeychain.setPassword(authenticator.secret,
                             forService: KEYCHAIN_SERVICE,
                             account: authenticator.serial)
    end

    def del_authenticator(authenticator)
      SSKeychain.deletePasswordForService(KEYCHAIN_SERVICE,
                                          account: authenticator.serial)
    end

    def authenticator_exists?(authenticator)
      serial = authenticator.is_a?(Bnet::Authenticator) ? authenticator.serial : Bnet::Attributes::Serial.new(authenticator).to_s
      !!SSKeychain.passwordForService(KEYCHAIN_SERVICE, account: serial)
    end

    private

    def authenticator_serials
      (SSKeychain.accountsForService(KEYCHAIN_SERVICE) || []).map do |v|
        v[KSecAttrAccount]
      end
    end
  end
end
