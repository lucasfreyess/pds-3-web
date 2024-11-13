# app/mailers/locker_mailer.rb
class LockerMailer < ApplicationMailer
  
  def locker_update_notification(locker)
    @locker = locker
    @owner = locker.owner_email
    @gestures = @locker.controller.user.model.gestures
    if @owner == ""
      
    else
      mail(to: @owner, subject: 'Actualización de tu casillero')
    end
    
  end
end
