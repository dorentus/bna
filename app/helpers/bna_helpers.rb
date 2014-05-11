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

class String
  def char_code_at(index)
    each_char.take(index + 1).last.bytes.first
  end

  # String#[index, length] does not like binary strings
  def substring_at(index, length: length)
    bytes.to_a[index, length].map(&:chr).join
  end

  def left_fix_to(length, pad_string: pad_string)
    substring_at(0, length: length).ljust(length, pad_string)
  end
end
