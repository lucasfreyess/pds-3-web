class Model < ApplicationRecord

  has_many :controllers, class_name: "Controller"
  has_many :gestures, class_name: "Gesture", dependent: :destroy
  has_many :users, class_name: "User"

  has_one_attached :model_file # Relación con ActiveStorage

  accepts_nested_attributes_for :gestures, allow_destroy: true

  validates :name, presence: { message: "Model name can't be blank" },
                    uniqueness: { message: "Model name must be unique" }
  validates :description, presence: { message: "Model description must be provided." }
  #validates :url, presence: { message: "Model URL must be provided." }
  #validates :version, presence: { message: "Model version must be provided." }
  
  validate :unique_gesture_names

  validate :print_errors

  def print_errors
    puts errors.full_messages
  end

  def set_url(new_url)
    # no lo he probado en el deploy pero ojala funcione..
    #self.update!(url: Rails.application.routes.url_helpers.rails_blob_url(self.model_file, host: host))
    self.update!(url: new_url)
    save
  end

  private

  def unique_gesture_names
    gesture_names = gestures.reject(&:marked_for_destruction?).map(&:name)
    unless gesture_names.uniq.size == gesture_names.size
      errors.add(:gestures, "deben tener nombres únicos dentro del mismo modelo.")
    end
  end

end
