class UserMailer < ApplicationMailer
    
    def welcome_email(mail)
    mail(to: mail, subject: 'Welcome to My Awesome Site')
    end
    #def welcome_email(otp, user)
    #@otp = otp
    #@user = user
    #mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    #end
end
