class Setting < ActiveRecord::Base
  after_initialize :init
  def init
    self.home_page_text ||= ""
    self.opens_at ||= Time.new
    self.closes_at ||= Time.new
    self.last_activation_date ||= Time.new
  end
end
