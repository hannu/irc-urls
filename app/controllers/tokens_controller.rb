class TokensController < ApplicationController
  before_filter :authenticate_user!
  def create
    current_user.regenerate_client_key!
    respond_to do |format|
      [:js, :json].each do |f|
        format.send(f) do
          render :json => "#{current_user.login}-#{current_user.secret_key}"
        end
      end
      format.html do
        flash[:confirm] = "Client key was successfully regenerated."
        redirect_to account_path
      end
    end
  end
end
