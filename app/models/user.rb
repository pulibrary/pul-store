class User < ActiveRecord::Base
# Connects this user object to Hydra behaviors.
 include Hydra::User

  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4

  before_create :default_values

# Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :rememberable, :trackable

  #:database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def default_values
    self.username ||= self.username
    self.email ||= "#{self.username}@princeton.edu"
  end

  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :email
        self.email = value
      end
    end
  end
end
