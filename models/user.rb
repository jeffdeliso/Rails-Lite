require 'bcrypt'

class User < ApplicationModel
  # Human.finalize!
  validates :username, presence: true, class: String, uniqueness: true
  validates :password_digest, presence: true
  validates :password, presence: true
  validates :session_token, presence: true, uniqueness: true


  belongs_to :house, class_name: :House, foreign_key: :house_id
  has_many :cats, class_name: :Cat, foreign_key: :owner_id

  attr_reader :password

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    user && user.is_password?(password) ? user : nil
  end

  def self.generate_token
    SecureRandom::urlsafe_base64
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def ensure_token
    self.session_token ||= User.generate_token
  end

  def reset_token!
    self.session_token = User.generate_token
    self.save
    self.session_token
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end
end