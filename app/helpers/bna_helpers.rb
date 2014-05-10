module BnaHelpers
  class << self
    def color_at_progress(progress)
      r = progress
      g = 0.5 - progress * 0.5
      b = 1
      UIColor.colorWithRed(r, green: g, blue: b, alpha: 1.0)
    end
  end
end
