module SettingsHelper
  def minutes
    range = Array(0...60)
    range.map do |m|
      ((m/10 < 1) ? "0" : "") + m.to_s
    end
  end

	def feature_options
		ops = {"none" => 0}
		Category.all.each do |c|
			c.menu_items.each do |i|
				ops[i.name] = i.id
			end
		end
		return ops
	end
end
