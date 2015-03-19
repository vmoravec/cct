class String
  def colorize color_code;  "#{color_code}#{self}\e[0m" end
  def red;   colorize("\e[0m\e[31m"); end
  def green; colorize("\e[0m\e[32m"); end
  def yellow;colorize("\e[0m\e[33m"); end
  def grey;  colorize("\e[0m\e[38m"); end
end

class Hash
  def deep_merge other_hash
    dup.deep_merge!(other_hash)
  end

  def deep_merge! other_hash
    other_hash.each_pair do |current_key, other_value|
      this_value = self[current_key]

      self[current_key] =
        if this_value.is_a?(Hash) && other_value.is_a?(Hash)
          this_value.deep_merge(other_value)
        elsif this_value.is_a?(Array) && this_value.first.is_a?(Hash)
          this_value.concat(other_value)
        else
          other_value
        end
    end

    self
  end
end

class Numeric
  # Stolen from https://www.ruby-forum.com/topic/126876
  def to_human
    return "0 B" if self.zero?
    units = %w{B KB MB GB TB}
    e = (Math.log(self)/Math.log(1024)).floor
    s = "%.2f " % (to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end
end

