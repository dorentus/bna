module TokenDisplay
  def self.included(base)
    base.class_eval do
      extend IB
      outlet :token_label, UILabel
      outlet :restorecode_label, UILabel
      attr_accessor :authenticator

      def update_token
        return if authenticator.nil?

        timestamp = Util.current_epoch
        token, _ = authenticator.get_token timestamp.to_i
        progress = Bnet::Authenticator.get_progress timestamp

        token_label.text = token
        token_label.textColor = Util.color_at_progress(progress)
      end

      def start_timer
        @timer = NSTimer.scheduledTimerWithTimeInterval(0.5,
                                                        target: self,
                                                        selector: :update_token,
                                                        userInfo: nil,
                                                        repeats: true)
        NSRunLoop.currentRunLoop.addTimer(@timer, forMode: NSRunLoopCommonModes)
      end

      def stop_timer
        return if @timer.nil?
        @timer.invalidate if @timer.valid?
        @timer = nil
      end

      def schedule(timer)
        timer.invalidate && return if authenticator.nil?
        update_token
      end
    end
  end
end
