class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard ||= UIStoryboard.storyboardWithName('MainStoryboard', bundle:nil)
    @window.rootViewController = @storyboard.instantiateInitialViewController
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible
    true
  end
end
