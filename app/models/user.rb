class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, 
  :rememberable, :validatable, :trackable, :omniauthable, 
  omniauth_providers: [:google_oauth2]

  has_many :controllers, class_name: "Controller"
  has_many :lockers, through: :controllers
  belongs_to :model, optional: true

  after_update :update_lockers_password_if_model_changed

  validates :name, presence: {message: "of this user must be present"}
  validates :email, presence: {message: "of this user must be present"}, 
                    uniqueness: {message: "is already used. Aborting user creation."}
  validates :password, presence: {message: "of this user must be present"}, if: :password_required?
  #validates :is_admin, presence: {message: "of this user must be present"} 
  
  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  """
  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(
        email: data['email'],
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end
  """

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # O cualquier campo adicional
    end
  end
  
  private

  def update_lockers_password_if_model_changed
    if saved_change_to_model_id? #nose si esto es legal?!?!?
      controllers.each(&:regenerate_lockers_passwords_if_model_changed)
    end
  end

  def password_required?
    new_record? || password.present?
  end
end
