class Setting < ActiveRecord::Base
  after_initialize :init
  def init
    self.home_page_text = ""
  end
end
