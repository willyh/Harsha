module OrdersHelper
  def available_times
    times = []
    now = round_up Time.now
    (1..24).each do |n|
      prospective_time = (now + (n*5).minutes ).strftime("%I:%M")
      times << prospective_time unless has_pickup_time? Order.all, prospective_time
    end 
    times << "Sorry We're Too Busy at the Moment" if times.empty?
    times
  end
  def round_up time
    dif = time.min - time.min / 5 * 5
    time + (5-dif).minutes
  end
  def has_pickup_time? orders, time
    orders.each do |o|
      return true if o.pickup_time == time
    end
    return false
  end
end
