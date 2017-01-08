class SessionsController < ApplicationController
  
require 'mixpanel-ruby'



  def new
  end


  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        tracker = Mixpanel::Tracker.new('872690784c41f5f6b2e84b0cf19c81bd')
        tracker.track(user.id, 'Signed In')
        tracker.people.set(user.id, {    # we already have user object, setting its ID using the object
    '$first_name'       => user.name,
    '$email'            => user.email
})
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy

  	log_out if logged_in?
    redirect_to root_url
  end

end
