class Setting < ActiveRecord::Base
  after_initialize :init

  has_attached_file :photo,
    :styles => {
			:fav => "16x16!",
			:iphone => "57x57!",
      :ipad => "72x72!",
      :highRes => "114x114!" }

  def init
    self.home_page_text ||= ""
    self.opens_at ||= Time.new
    self.closes_at ||= Time.new
    self.last_activation_date ||= Time.new
  end

end
