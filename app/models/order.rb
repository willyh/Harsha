class Order < ActiveRecord::Base
  has_many :selections
  has_many :menu_items, :through => :selections
  has_one :payment_notification

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
    menu_items.each do |item|
      values.merge!({
        "amount_#{item.id}" => item.price,
        "item_name_#{item.id}"=> item.name,
        "item_number_#{item.id}" => item.id,
        "quantity_#{item.id}" => 1
      })
    end
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

  def update_price
    p = 0
    arr = self.items.split("\n")
    arr.each do |item|
      p += MenuItem.find_by_name(item).price
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
    self.completed = true
    self.save(false)
  end

  private

  def init
    self.price ||= 0
    self.secret ||= rand(36**8).to_s(36)
    self.completed ||= false
  end

end

