class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @storyboard ||= UIStoryboard.storyboardWithName('MainStoryboard', bundle:nil)
    @window.rootViewController = @storyboard.instantiateInitialViewController
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible
    true
  end

  def applicationWillResignActive(application)
    UIGraphicsBeginImageContextWithOptions(@window.bounds.size, false, UIScreen.mainScreen.scale)
    if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1
      @window.drawViewHierarchyInRect(@window.bounds, afterScreenUpdates:true)
    else
      @window.layer.renderInContext UIGraphicsGetCurrentContext()
    end
    @screenshot = UIGraphicsGetImageFromCurrentImageContext().applyDarkEffect

    UIGraphicsEndImageContext();

    @overlay_view = UIImageView.alloc.initWithFrame @window.bounds
    @overlay_view.image = @screenshot
    @window.addSubview @overlay_view
  end

  def applicationDidBecomeActive(application)
    @overlay_view.removeFromSuperview unless @overlay_view.nil?
    @overlay_view = nil
  end
end
