module BnaDisplayLinkExt
  def self.included(base)
    base.class_eval do
      attr_accessor :timer

      def viewWillAppear(animated)
        @timer = CADisplayLink.displayLinkWithTarget(self, selector: :update_display_link_timer)
        @timer.addToRunLoop(NSRunLoop.currentRunLoop, forMode: NSRunLoopCommonModes)
      end

      def viewDidDisappear(animated)
        @timer.invalidate if @timer
        @timer = nil
      end
    end
  end
end
