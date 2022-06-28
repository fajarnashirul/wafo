class User < ApplicationRecord
  has_secure_password
  belongs_to :role, polymorphic: true, optional: true

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true
  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }
  validates :role_id, presence: false
  validates :role_type, presence: false

  def admin_role?
    role_type == "Admin"
  end

  def customer_role?
    role_type == "Customer"
  end

  def merchant_role?
    role_type == "Merchant"
  end

  def as_admin(admin_params)
    update(role: Admin.new(admin_params))
  end

  def as_customer(customer_params)
    update(role: Customer.new(customer_params))
  end

  def as_merchant(merchant_params)
    update(role: Merchant.new(merchant_params))
  end

  def generate_token!
    self.reset_token = generate_token
    self.reset_token_sent_at = Time.now
    save!
  end
  
  def token_valid?
    (self.reset_token_sent_at + 4.hours.to_i) > Time.now
  end
  
  def reset_password!(password)
    self.reset_token = nil
    self.password = password
    save!
  end
  
  def update_new_email!(email)
    self.email = email
    self.reset_token = nil
    save
  end
  
  def self.email_used?(email)
    if User.where(email: email).any?
      return true
    end
  end

  private
  
  def generate_token
    SecureRandom.hex(10)
  end
  
end
