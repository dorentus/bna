module MainViewControllerProgressView
  def add_progressview
    @progressview = UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault)
    @progressview.trackTintColor = UIColor.clearColor
    @progressview.progress = 0.5
    @progressview.translatesAutoresizingMaskIntoConstraints = false
    self.navigationController.view.addSubview @progressview

    self.navigationController.view.addConstraints NSLayoutConstraint.constraintsWithVisualFormat("V:[navbar]-(-2)-[progressview]",
                                                                            options: NSLayoutFormatDirectionLeadingToTrailing,
                                                                            metrics: nil,
                                                                            views: { "navbar" => self.navigationController.navigationBar, "progressview" => @progressview })
    self.navigationController.view.addConstraints NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressview]|",
                                                                            options: NSLayoutFormatDirectionLeadingToTrailing,
                                                                            metrics: nil,
                                                                            views: {"progressview" => @progressview})

    @timer = CADisplayLink.displayLinkWithTarget(self, selector: :update_progress)
    @timer.addToRunLoop(NSRunLoop.currentRunLoop, forMode: NSRunLoopCommonModes)
  end

  def update_progress
    return if @progressview.nil?
    progress = Bnet::Authenticator.get_progress
    @progressview.progress = progress
    @progressview.progressTintColor = BnaHelpers.color_at_progress(progress)
  end
end
