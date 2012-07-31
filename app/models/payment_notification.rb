class PaymentNotification < ActiveRecord::Base
  belongs_to :order
  serialize :params
  after_create :mark_order_as_completed

  private

  def mark_order_as_completed
    if status == "Completed"#&& params[:secret] == APP_CONFIG[:paypal_secret]
      order.complete
    end
  end
end
