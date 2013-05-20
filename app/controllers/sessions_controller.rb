class SessionsController < ApplicationController
  skip_before_filter :authorize, only: [:new, :new_admin, :create, :create_admin]
  def create
    guest_by_email = Guest.find_by_email(params[:login])
    guest_by_sitekey = Guest.find_by_sitekey(params[:login])
    if guest_by_email 
      if !guest_by_email.admin
        session[:guest_id] = guest_by_email.id
        if guest_by_email.registered?
          redirect_to home_url
        else
          redirect_to modify_party_guests_url
        end
      else
        redirect_to login_admin_url(login: params[:login])
      end
    elsif guest_by_sitekey
      if guest_by_sitekey.registered?
        redirect_to login_url, alert: "Please use your registered email to login"
      else
        session[:guest_id] = guest_by_sitekey
        redirect_to modify_party_guests_url
      end
    else 
      redirect_to login_url, alert: "Invalid login"
    end
  end

  def create_admin
    logger.debug("Login is ...#{params[:login]}")
    guest = Guest.find_by_email(params[:login])
    if guest and guest.password == params[:password]
      session[:guest_id] = guest.id
      redirect_to home_url
    else
      redirect_to login_admin_url(login: params[:login]), alert:"Wrong Password"
    end
  end

  def destroy
    session[:guest_id] = nil
    redirect_to login_url, alert: "Logged out"
  end


end