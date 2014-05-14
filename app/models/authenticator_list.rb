class AuthenticatorList
  KEYCHAIN_SERVICE = 'bna_authenticators'
  USERDEFAULTS_KEY = 'bna_authenticator_serials'

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
      keychain_add_authenticator(authenticator) && userdefaults_add_authenticator(authenticator)
    end

    def del_authenticator(authenticator)
      keychain_del_authenticator(authenticator) && userdefaults_del_authenticator(authenticator)
    end

    def move_authenticator_at(from, to: to)
      userdefaults_move_authenticator_at(from, to: to)
    end

    def authenticator_exists?(authenticator)
      serial = authenticator.is_a?(Bnet::Authenticator) ? authenticator.serial : Bnet::Attributes::Serial.new(authenticator).to_s
      !!SSKeychain.passwordForService(KEYCHAIN_SERVICE, account: serial)
    end

    private

    def authenticator_serials
      a = userdefaults_authenticator_serials.to_a
      b = keychain_authenticator_serials
      a - (a - b) + (b - a)
    end

    def keychain_add_authenticator(authenticator)
      SSKeychain.setPassword(authenticator.secret,
                             forService: KEYCHAIN_SERVICE,
                             account: authenticator.serial)
    end

    def keychain_del_authenticator(authenticator)
      SSKeychain.deletePasswordForService(KEYCHAIN_SERVICE,
                                          account: authenticator.serial)
    end

    def keychain_authenticator_serials
      SSKeychain.accountsForService(KEYCHAIN_SERVICE).to_a.map do |v|
        v[KSecAttrAccount]
      end
    end

    def userdefaults_move_authenticator_at(from, to: to)
      serials = authenticator_serials.dup
      serials.insert(to, serials.delete_at(from))
      userdefaults_save(serials)
    end

    def userdefaults_add_authenticator(authenticator)
      serials = authenticator_serials.dup
      serials << authenticator.serial unless serials.last == authenticator.serial
      userdefaults_save(serials)
    end

    def userdefaults_del_authenticator(authenticator)
      serials = authenticator_serials.dup
      serials.delete authenticator.serial
      userdefaults_save(serials)
    end

    def userdefaults_authenticator_serials
      NSUserDefaults.standardUserDefaults.objectForKey(USERDEFAULTS_KEY)
    end

    def userdefaults_save(serials)
      NSUserDefaults.standardUserDefaults.setObject(serials, forKey: USERDEFAULTS_KEY)
    end
  end
end
