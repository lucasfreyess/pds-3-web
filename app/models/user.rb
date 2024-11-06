class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, 
  :rememberable, :validatable, :trackable, :omniauthable, 
  omniauth_providers: [:google_oauth2]

  #def self.from_omniauth(access_token)
  #  data = access_token.info
  #  user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
  #  unless user
  #    user = User.create(
  #      email: data['email'],
  #      password: Devise.friendly_token[0,20]
  #    )
  #  end
  #  user
  #end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # O cualquier campo adicional
    end
  end
  
end
