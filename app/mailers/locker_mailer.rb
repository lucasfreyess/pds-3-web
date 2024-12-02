# app/mailers/locker_mailer.rb
class LockerMailer < ApplicationMailer
  
  def locker_update_notification(locker)
    @locker = locker
    @owner = locker.owner_email

    # Verifica si el locker tiene un propietario
    if @owner == ""
      return
    end

    # Obtener todos los gestos disponibles y filtrar según los nombres en la contraseña
    all_gestures = @locker.controller.user.model.gestures
    
    @gestures = @locker.password.map do |gesture_name|
      gesture = all_gestures.find_by(name: gesture_name)
      if gesture&.image&.attached?
        # Cargar la imagen y asignarle un CID único, asegurando que tenga el formato correcto
        image_cid = "gesture_image_#{gesture.id}"
        image_format = gesture.image.filename.extension_with_delimiter # Obtiene la extensión del archivo
        attachments.inline[image_cid] = {
          mime_type: gesture.image.content_type,
          content: gesture.image.download
        }
        { gesture: gesture, image_cid: image_cid }
      else
        { gesture: gesture, image_cid: nil }
      end
    end

    #mail(to: @owner, subject: 'Actualización de tu casillero')
    puts "EMAIL DE ACTUALIZACION DE CLAVES DE CASILLERO ENVIADO..."
  end

  def locker_opening_notification(locker)

    @locker = locker
    @owner = locker.owner_email
    @locker_opening = locker.locker_openings.last

    # Verifica si el locker tiene un propietario
    if @owner == ""
      return
    end

    mail(to: @owner, subject: 'Tu casillero ha sido abierto')
    puts "EMAIL DE APERTURA DE CASILLERO ENVIADO..."

  end
end

