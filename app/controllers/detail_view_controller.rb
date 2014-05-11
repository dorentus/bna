class DetailViewController < UIViewController
  extend IB

  outlet :token_label, UILabel
  outlet :restorecode_label, UILabel
  outlet :countdown_view, UIProgressView

  attr_accessor :authenticator

  def viewDidLoad
    super

    self.title = authenticator.serial
    restorecode_label.text = authenticator.restorecode
    update_token
  end

  def viewWillAppear(animated)
    super(animated)
    @timer = NSTimer.scheduledTimerWithTimeInterval(0.5,
                                                    target: self,
                                                    selector: :update_token,
                                                    userInfo: nil,
                                                    repeats: true)
    NSRunLoop.currentRunLoop.addTimer(@timer, forMode: NSRunLoopCommonModes)
  end

  def viewDidDisappear(animated)
    super(animated)
    @timer.invalidate if (@timer && @timer.valid?)
    @timer = nil
  end

  def update_token
    return if authenticator.nil?

    timestamp = Time.now.getutc.to_f
    token, _ = authenticator.get_token timestamp.to_i
    progress = Bnet::Authenticator.get_progress timestamp

    token_label.text = token
    token_label.textColor = BnaHelpers.color_at_progress(progress)
  end
end
