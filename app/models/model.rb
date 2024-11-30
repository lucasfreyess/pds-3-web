class Model < ApplicationRecord

  has_many :controllers, class_name: "Controller"
  has_many :gestures, class_name: "Gesture", dependent: :destroy
  has_many :users, class_name: "User"
  
  has_one_attached :model_file # Relación con ActiveStorage

  accepts_nested_attributes_for :gestures, allow_destroy: true

  #after_create :set_url

  validates :name, presence: { message: "Model name can't be blank" }
  validates :description, presence: { message: "Model description must be provided." }
  #validates :url, presence: { message: "Model URL must be provided." }
  #validates :version, presence: { message: "Model version must be provided." }
  
  #validate :must_have_at_least_six_gestures

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  def set_url(host)
    # no lo he probado en el deploy pero ojala funcione..
    self.update!(url: "#{Rails.application.routes.url_helpers.model_url(self, host: host)}/json")
    save
  end

  private

  #def must_have_at_least_six_gestures
  #  if gestures.size < 6
  #    errors.add(:gestures, "Model must have at least six gestures.")
  #  end
  #end

end