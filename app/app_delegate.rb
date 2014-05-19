class AppDelegate
  COLOR_BACKGROUND = 0xfffaf0.uicolor
  COLOR_HIGHLIGHTED = 0xf5deb3.uicolor

  attr_accessor :window

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    apply_themes
    true
  end

  private

  def apply_themes
    UINavigationBar.appearance.barTintColor = COLOR_BACKGROUND
    UITableView.appearance.backgroundColor = COLOR_BACKGROUND
    UIView.appearanceWhenContainedIn(UITableView, nil).backgroundColor = UIColor.clearColor

    AuthenticatorCell::SelectionBackgroundView.appearanceWhenContainedIn(UITableView, nil).backgroundColor = COLOR_HIGHLIGHTED
  end
end
