class Setting < ActiveRecord::Base
  after_initialize :init

  has_attached_file :photo,
    :styles => {
			:small => "100x100",
      :medium => "280x",
      :large => "640x" }

  def init
    self.home_page_text ||= ""
    self.opens_at ||= Time.new
    self.closes_at ||= Time.new
    self.last_activation_date ||= Time.new
  end

end
