module MenuItemsHelper
  def format_price price
    if price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end
  
  def separate_and categories
    hash = {}
    categories.each do |index, cats|
      hash[index/3 + 1] ||= []
      hash[index/3 + 1] << cats
    end
    hash
  end

  def assign_numbers_to categories
    hash = {}
    index = 0
    categories.each do |category|
      hash[index] = category
      index += 0
    end
    hash
  end
end
