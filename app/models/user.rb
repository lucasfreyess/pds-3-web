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

  # validates :name, presence: {message: "of this user must be present"}
  validates :email, presence: {message: "of this user must be present"},
                    uniqueness: {message: "is already used. Aborting user creation."}
  validates :password, presence: {message: "of this user must be present"}, if: :password_required?
  #validates :is_admin, presence: {message: "of this user must be present"}

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  def self.from_google(u)

    if u[:email].match?(/@miuandes\.cl$/)
      create_with(uid: u[:uid], provider: 'google',
                password: Devise.friendly_token[0, 20], is_admin: true).find_or_create_by!(email: u[:email])
    else
      create_with(uid: u[:uid], provider: 'google',
                password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email])
    end
  end

  # metodo para admin y usuario normal
  def locker_openings_last_7_days
    if self.is_admin
      openings = LockerOpening.all
      .where("locker_openings.opened_at >= ?", 7.days.ago.beginning_of_day)

      successful_openings = openings.where(was_succesful: true)
        .group("DATE(locker_openings.opened_at)")
        .order("DATE(locker_openings.opened_at) DESC")
        .count

      failed_openings = openings.where(was_succesful: false)
        .group("DATE(locker_openings.opened_at)")
        .order("DATE(locker_openings.opened_at) DESC")
        .count

      return { successful: successful_openings, failed: failed_openings }
    else
      openings = LockerOpening.joins(locker: { controller: :user })
      .where(controllers: { user_id: id })
      .where("locker_openings.opened_at >= ?", 7.days.ago.beginning_of_day)

      successful_openings = openings.where(was_succesful: true)
        .group("DATE(locker_openings.opened_at)")
        .order("DATE(locker_openings.opened_at) DESC")
        .count

      failed_openings = openings.where(was_succesful: false)
        .group("DATE(locker_openings.opened_at)")
        .order("DATE(locker_openings.opened_at) DESC")
        .count

      return { successful: successful_openings, failed: failed_openings }
    end
  end

  #modelo mas usado por usuarios normales en los ultimos 7 dias
  def most_used_model_last_7_days
    Model.joins(:users)
    .where(users: { is_admin: false })
    .where("users.updated_at >= ?", 7.days.ago.beginning_of_day)
    .group(:id)
    .order("COUNT(users.id) DESC")
    .first
  end

  # usuarios normales unicos que han cambiado su modelo en los ultimos 7 dias
  def unique_users_changed_model_last_7_days
    User.joins(:model)
    .where(is_admin: false)
    .where("users.updated_at >= ?", 7.days.ago.beginning_of_day)
    .distinct(:id)
  end

  # para saber el casillero que mas veces se ha intentado abrir, en los ultimos siete dias
  # metodo para usuario normal
  def most_opened_locker_last_7_days
    Locker.joins(controller: :user)
    .where(controllers: { user_id: id })
    .joins(:locker_openings)
    .where("locker_openings.opened_at >= ?", 7.days.ago.beginning_of_day)
    .group(:id)
    .order("COUNT(locker_openings.id) DESC")
    .first
  end

  # numero de dueños unicos que han abierto sus casilleros en los ultimos 7 dias
  # metodo para usuario normal
  def unique_owners_opened_last_7_days
    Locker.joins(controller: :user)
    .where(controllers: { user_id: id })
    .joins(:locker_openings)
    .where("locker_openings.opened_at >= ?", 7.days.ago.beginning_of_day)
    .distinct(:owner_email)
    .count
  end

  # Tiempo promedio de apertura de casilleros en los últimos 7 días
  # metodo para usuario normal
  def average_opening_time_last_7_days
    locker_openings = LockerOpening.joins(locker: :controller)
                                   .where(controllers: { user_id: id })
                                   .where('opened_at >= ?', 7.days.ago)
                                   .where.not(closed_at: nil)

    return 0 if locker_openings.empty?

    puts "LOCKER OPENINGS #{locker_openings.inspect}"

    total_time = locker_openings.sum { |opening| opening.closed_at - opening.opened_at }
    (total_time / locker_openings.size).round(2) # Tiempo promedio en segundos
  end

  # Tiempo promedio de apertura por modelo en los últimos 7 días
  def average_opening_time_by_model_last_7_days
    return {} unless self.is_admin

    models_with_averages = {}

    puts "ACTIVANDOO AVERAGE OPENING TIME BY MODEL"

    Model.includes(users: { controllers: { lockers: :locker_openings } }).find_each do |model|
      locker_openings = LockerOpening.joins(locker: { controller: :user })
                                     .where(users: { id: model.users.ids })
                                     .where('opened_at >= ?', 7.days.ago)
                                     .where.not(closed_at: nil)

      #puts "LOCKER OPENINGS #{locker_openings.inspect}"

      next if locker_openings.empty?

      total_time = locker_openings.sum { |opening| opening.closed_at - opening.opened_at }
      average_time = (total_time / locker_openings.size).round(2)
      models_with_averages[model.name] = average_time
    end

    return models_with_averages
  end

  # para determinar los modelos con mas aperturas fallidas en los ultimos 7 dias
  # solo se puede acceder si current_user.is_admin
  def models_with_most_failed_openings_last_7_days
    return {} unless self.is_admin
  
    models_with_failures = {}
  
    Model.includes(users: { controllers: { lockers: :locker_openings } }).find_each do |model|
      failed_openings = LockerOpening.joins(locker: { controller: :user })
                                     .where(users: { id: model.users.ids })
                                     .where('opened_at >= ?', 7.days.ago)
                                     .where(was_succesful: false)
                                     .count
  
      models_with_failures[model.name] = failed_openings if failed_openings.positive?
    end
  
    # Ordenar por cantidad de fallos descendente
    return models_with_failures.sort_by { |_model_name, failures| -failures }.to_h
  end
  

  # para determinar la cantidad de controladores activos (solo se puede acceder si current_user.is_admin)
  def active_controllers
    if self.is_admin
      Controller.all.select(&:is_active).count
    end
  end

  # para determinar la cantidad de casilleros activos (solo se puede acceder si current_user.is_admin)
  def active_lockers
    if self.is_admin
      Locker.all.select(&:is_active).count
    end
  end

  # para determinar la cantidad de usuarios activos (solo se puede acceder si current_user.is_admin)
  def active_users
    if self.is_admin
      User.all.select(&:is_active).count
    end
  end

  # para determinar si un usuario normal esta activo
  def is_active
    if !self.is_admin
      self.current_sign_in_at >= 10.minutes.ago
    end
  end

  private

  def update_lockers_password_if_model_changed
    #nose si esto es legal?!?!? update: si funciona!!
    if saved_change_to_model_id?
      controllers.each(&:regenerate_lockers_passwords_if_model_changed)
    end
  end

  def password_required?
    new_record? || password.present?
  end

end
