class UserMailer < ApplicationMailer
    
    #def welcome_email(user)
    #@otp = user
    #mail(to: 'sirishagodina9@gmail.com', subject: 'Welcome to My Awesome Site')
    #end
    def welcome_email(otp, user)
    @otp = otp
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    end
end
