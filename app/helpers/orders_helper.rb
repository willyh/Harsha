module OrdersHelper
  def format_price price
    if price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end
  def available_times
    times = []
    now = round_up Time.now.utc - 4.hours
    (1..24).each do |n|
      prospective_time = format_time((now + (n*time_interval).minutes ).strftime("%I:%M%p"))
      times << prospective_time unless has_pickup_time? Order.all, prospective_time
    end 
    times << "Sorry We're Too Busy at the Moment" if times.empty?
    times
  end
  def round_up time
    dif = time.min - time.min / time_interval * time_interval
    time + (time_interval-dif).minutes
  end
  def has_pickup_time? orders, time
    orders.each do |o|
      return true if o.pickup_time == time
    end
    return false
  end
  def remove_item order, item
    arr = order.items.split("\n")
    if arr.delete_at arr.index(item)
      items = arr.join("\n")
      price = order.price - item.split(" ").first.delete("$").to_f
      order.update_attributes(:items => items, :price => price)
    end
  end
  def calculate_price items
    p = 0
    items.each do |item|
      p += MenuItem.find_by_name(item).price
    end
    p
  end

  def format_time time
    return time.slice(1,6) if time.first == "0"
    time
  end

  def time_interval
    5
  end

  def build_tables(categories)
    i = 3
    three_category_sets = {}
    categories.each do |cat, item|
      three_category_sets[i/3] ||= []
      three_category_sets[i/3] << cat
      i = i+1
    end
    tables = {}
    tables[:category_sets] = three_category_sets
    three_category_sets.each do |index, category_set|
      tables[index] = build_table(category_set)
    end
    tables
  end

  def build_table categories
    table = {}
    table[1] = {}
    MenuItem.all.each do |item|
      check 1, table, item, categories unless item.out_of_stock
    end
    table
  end

  def check index, table, item, categories
    if categories.include? item.category
      table[index] ||= {} 
      if table[index][item.category]
        check index + 1, table, item, categories
      else
        table[index][item.category] = item
      end
    end
  end
end
