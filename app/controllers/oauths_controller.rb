class OauthsController < ApplicationController
  before_action :require_login, only: :destroy

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = params[:provider]

    if @user = login_from(:google)

       session[:access_token] = @access_token.token
       flash[:alert] = "Logged in from Google!"

       redirect_to root_path
    else
      # if logged_in?
      #   link_account(:google)
      #   flash[:notice] = "Account linked from Google!"
      #   redirect_to user_path(@user)
      # else
        @user = create_from(:google)
        reset_session # protect from session fixation attack
        session[:access_token] = @access_token.token
        auto_login(@user)
        flash[:alert] = 'Google account successfully linked!'
        redirect_to root_path
      # end
    end
  end

  def destroy
    provider = params[:provider]

    authentication = current_user.authentications.find_by_provider(provider)
    if authentication.present?
      authentication.destroy
      # logout
      flash[:alert] = "You have successfully logged out."
    else
      flash[:alert] = "Logout failed."
    end
    redirect_to root_path
  end
end
