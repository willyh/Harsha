module SettingsHelper
  def minutes
    range = Array(0...60)
    range.map do |m|
      ((m/10 < 1) ? "0" : "") + m.to_s
    end
  end

	def feature_options
		ops = {}
		Category.all.each do |c|
			c.menu_items.select{|i|i.in_stock}.each do |i|
				ops.merge!({i.name => i.id})
			end
		end
		ops = ops.sort.unshift(["none", 0])
		return ops
	end
end
