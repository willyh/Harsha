module MenuItemsHelper
  def format_price price
    if price <= 0
      "free"
    elsif price.to_s =~ /\d*.\d/
      "$#{price}0"
    else
      "$#{price}"
    end
  end
end
