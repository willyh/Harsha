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
		logger.info Time.now
    now = round_up Time.now
		logger.info now
		opens_at = @settings.opens_at.localtime
    if now.hour < opens_at.hour
      now = Time.local(now.year, now.month, now.day, opens_at.hour, opens_at.min, 0)
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
    time = time + (time_interval-dif).minutes
		time = time.change(:sec => 0)
		time = time.change(:usec => 0)
  end

  def has_pickup_time? time
    @settings = Setting.first
		closes_at = @settings.closes_at.localtime
		opens_at = @settings.opens_at.localtime
    valid = Order.all.select{|o|o.pickup_time == time}.count < @settings.max_per_slot || @settings.max_per_slot < 0
		valid = valid && time < closes_at
		valid = valid && opens_at < time
  end

  def format_time time
    return "" unless time
    time_s = time.localtime.strftime("%I:%M%p")
    return time_s.slice(1,6) if time_s.first == "0"
    time_s
  end

  def time_interval
    Setting.first.interval
  end

  def next_time
    now = round_up Time.now
		opens_at = Setting.first.opens_at.localtime
    if now < opens_at
      now = Time.local(now.year, now.month, now.day, opens_at.hour, opens_at.min)
    end
    prospective_time = (now + (1*time_interval).minutes)
    times = {(format_time prospective_time) => prospective_time}
    times["Sorry, there are no available time slots"] = "-1" if times.empty?
    return times
  end

end
