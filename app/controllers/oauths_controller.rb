class OauthsController < ApplicationController
  #skip_before_filter :require_login
  before_action :require_login, only: :destroy
  # sends the user on a trip to the provider,
  # and after authorizing there back to the callback url.
  def oauth
    login_at(params[:provider])
  end
  # this is where all of the magic happens
  def callback
    provider = params[:provider]
    # @access_token =
    if @user = login_from(:google)
      # user has already linked their account with google
      # @user.google_access_token = @access_token.token
      flash[:notice] = "Logged in using #{provider.titleize}!"
      redirect_to root_path
    else
      # User has not linked their account with Github yet. If they are logged in,
      # authorize the account to be linked. If they are not logged in, require them
      # to sign in. NOTE: If you wanted to allow the user to register using oauth,
      # this section will need to be changed to be more like the wiki page that was
      # linked earlier.
      # if logged_in?
      #   # link_account(:google)
      #   link_account(provider)
      #   flash[:notice] = "Account linked from #{provider.titleize}!"
      #   redirect_to user_path(@user)
      # else
      @user = create_from(:google)
      auto_login(@user)
      flash[:alert] = 'Google account successfully linked.'
      redirect_to user_url(@user)
      # end
    end
  end
  # This is used to allow users to unlink their account from the oauth provider.
  #
  # In order to use this action you will need to include this route in your routes file:
  # delete "oauth/:provider" => "oauths#destroy", :as => :delete_oauth
  #
  # You will need to provide a 'provider' parameter to the action, create a link like this:
  # link_to 'unlink', delete_oauth_path('github'), method: :delete
  def destroy
    provider = params[:provider]

    authentication = current_user.authentications.find_by_provider(provider)
    if authentication.present?
      authentication.destroy
      flash[:notice] = "You have successfully unlinked your #{provider.titleize} account."
    else
      flash[:alert] = "You do not currently have a linked #{provider.titleize} account."
    end
    logout
    redirect_to root_path
  end
end
  # private
  # def link_account(provider)
  #   if @user = add_provider_to_user(provider)
  #     If you want to store the user's Github login, which is required in order to interact with their Github account, uncomment the next line.
  #     You will also need to add a 'github_login' string column to the users table.
  #
  #     @user.update_attribute(:google_login, @user_hash[:user_info]['login'])
  #     flash[:notice] = "You have successfully linked your Google account."
  #   else
  #     flash[:alert] = "There was a problem linking your Google account."
  #   end
  # end

#   def auth_params
#     params.permit(:provider, :code)
#   end
# end
