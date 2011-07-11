module MenuItemsHelper
  def format_price price
    if price <= 0
      "free"
    elsif price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end
end
