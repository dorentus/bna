# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = '👾'
  app.identifier = 'rox.dorentus.bna'
  app.frameworks << 'QuartzCore' << 'Security'
  app.vendor_project('vendor/NSData+Digest', :static)
  app.pods do
    pod 'SSKeychain'
    pod 'MMProgressHUD'
  end
  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ] if ENV['TRAVIS'].nil?
  app.files_dependencies 'app/helpers/bna_helpers.rb' => 'app/lib/bnet/authenticator.rb'
end
