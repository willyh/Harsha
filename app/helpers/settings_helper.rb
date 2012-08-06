module SettingsHelper
  def minutes
    range = Array(0...60)
    range.map do |m|
      ((m/10 < 1) ? "0" : "") + m.to_s
    end
  end
end
