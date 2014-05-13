class AuthenticatorCell < UITableViewCell
  extend IB

  DEFAULT_HEIGHT = 88

  attr_accessor :authenticator

  outlet :token_label, UILabel
  outlet :serial_label, UILabel

  def start_timer
    @timer = NSTimer.scheduledTimerWithTimeInterval(0.5,
                                                    target: self,
                                                    selector: :"schedule:",
                                                    userInfo: nil,
                                                    repeats: true)
    NSRunLoop.currentRunLoop.addTimer(@timer, forMode: NSRunLoopCommonModes)
  end

  def stop_timer
    return unless @timer
    @timer.invalidate if @timer.valid?
    @timer = nil
  end

  def schedule(timer)
    timer.invalidate && return if authenticator.nil?
    update_token
  end

  def update_token
    return if authenticator.nil?

    timestamp = Time.now.to_i
    token, next_timestamp = authenticator.get_token(timestamp)
    progress = 1.0 - (next_timestamp - timestamp) / 30.0

    token_label.text = token

    token_label.textColor = BnaHelpers.color_at_progress(progress)
  end

  def authenticator=(a_authenticator)
    @authenticator = a_authenticator
    serial_label.text = authenticator.serial
    update_token
  end
end
