module ApplicationHelper
  def active?
    return Setting.first.last_activation_date < Time.now && Time.now < Setting.first.closes_at
  end
end
