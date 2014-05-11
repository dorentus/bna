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
  app.name = 'Bna'
  app.identifier = 'rox.dorentus.bna'
  app.frameworks << 'QuartzCore' << 'Security'
  app.vendor_project('vendor/NSData+Digest', :static)
  app.entitlements['keychain-access-groups'] = [app.seed_id + '.' + app.identifier]
  app.pods do
    pod 'SSKeychain'
    pod 'HTProgressHUD'
  end
end
