class Order < ActiveRecord::Base
  has_many :selections
  has_many :menu_items, :through => :selections
  has_one :payment_notification

  before_save :validate_pickup_time
  after_initialize :init

  attr_accessible :customer_name, :pickup_time, :price, :completed

  def paypal_encrypted(return_url, notify_url)
    values = {
      :business => APP_CONFIG['paypal_email'],
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => id,
      :no_shipping => 1,
      :no_note => 1,
      :notify_url => notify_url,
      :cert_id => APP_CONFIG['paypal_cert_id']
    }
    items = {:amount_1 => 0.3, :item_name_1 => "Paypal fee", :item_number_1 => 0, :quantity_1 => 1}
    index = 2
    selections.each do |s|
      item = s.menu_item
      items["amount_#{index}"] = item.price
      items["item_name_#{index}"] = item.name
      items["item_number_#{index}"] = item.id
      items["quantity_#{index}"] = 1
      index += 1

      s.options.select{|o| o.price > 0}.each {|o|
        items["amount_#{index}"] = o.price
        items["item_name_#{index}"] = (o.price <= 0) ? "No #{o.name}" : o.name
        items["item_number_#{index}"] = o.id
        items["quantity_#{index}"] = 1
        index += 1
      }
      
    end
    values.merge!(items)

    encrypt_for_paypal(values)
  end

  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
  APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
  APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")

  def encrypt_for_paypal(values)
    signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
    OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end

  def format_price price
    if price.to_s =~ /\d*[.]\d{2,}/
      "$#{price}"
    else
      "$#{price}0"
    end
  end

  def update_price!
    p = 0.3
    self.selections.each do |s|
      p += s.menu_item.price
      s.options.each do |o|
        p += o.price
      end
    end
    self.price = p
  end

  def add_items hash
    item = hash["item_addition"]
    if item
      arr =item.split(" ")
      item_price = arr.delete_at(0).to_f
      hash[:price] = self.price + item_price
      hash[:items] = (self.items || "") + format_price(item_price) + " " + arr.join(" ")+ "\n"
    end
    hash
  end
  
  def complete
    self.completed = true
    self.save
  end

  def print
		File.open("receipts/#{id}",'w') {|f| f.write(self)}
		%x[lp receipts/#{id}]
  end

	def to_s
		s = "Order: ##{id}\n"
		s += "Name: #{customer_name}\n"
		s += "Total: #{format_price price}\n"
		s += "Pickup: #{pickup_time.localtime.strftime("%I:%M%p")}\n"
		selections.each do |sel|
			s += "  #{sel.menu_item.name}\n"
			sel.options.each do |o|
				s += "  - NO #{o.name}\n" if o.price <= 0
				s += "  - #{o.name}\n" if o.price > 0
			end
		end
		30.times do s += "-" end
		return s
	end
  private

  def init
    self.price ||= 0.3
    self.secret ||= rand(36**8).to_s(36)
    self.completed ||= false
  end

  def validate_pickup_time
    self.pickup_time = nil unless self.completed
  end

end
