module OrdersHelper
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
end
