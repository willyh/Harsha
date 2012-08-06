module OrdersHelper
  def format_price price
    if price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end
  def available_times
    @settings = Setting.first
    times = {}
    now = round_up Time.now
    if now.hour < @settings.opens_at.hour
      now = Time.local(now.year, now.month, now.day, @settings.opens_at.hour, @settings.opens_at.min)
    end
    (1..24).each do |n|
      prospective_time = (now + (n*time_interval).minutes)
      times[format_time prospective_time] = prospective_time if has_pickup_time? prospective_time
    end 
    times["Sorry, there are no available time slots"] = "-1" if times.empty?
    times.sort_by{ |string, val| val }
  end

  def round_up time
    dif = time.min - time.min / time_interval * time_interval
    time + (time_interval-dif).minutes
  end

  def has_pickup_time? time
    @settings = Setting.first
    valid = Order.all.select{|o|o.pickup_time == time}.count <= @settings.max_per_slot
    if @settings.closes_at.hour == time.hour
      valid = valid && @settings.closes_at.min > time.min
    else
      valid = valid && @settings.closes_at.hour > time.hour
    end
    if @settings.opens_at.hour == time.hour
      valid = valid && @settings.opens_at.min < time.min
    else
      valid = valid && @settings.opens_at.hour < time.hour
    end
  end

  def format_time time
    return "" unless time
    time_s = time.strftime("%I:%M%p")
    return time_s.slice(1,6) if time_s.first == "0"
    time_s
  end

  def time_interval
    Setting.first.interval
  end

  def next_time
    now = round_up Time.now.utc - 4.hours
    prospective_time = (now + (1*time_interval).minutes)
    times = {(format_time prospective_time) => prospective_time}
    times["Sorry, there are no available time slots"] = "-1" if times.empty?
    return times
  end


end
