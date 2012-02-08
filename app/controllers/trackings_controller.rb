class TrackingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @trackings = current_user.trackings.all(:include => :channel, :order => "#{Channel.table_name}.name")
  end

  def show
  end

  def create
  end

  def update
    params[:tracking].assert_valid_keys('publicity')
    params[:tracking][:publicity] = nil if params[:tracking][:publicity] == "deactivate"
    @tracking = current_user.trackings.find(params[:id])
    respond_to do |format|
      if (@tracking.update_attributes(params[:tracking]))
        format.js
        format.html do
          flash[:notice] = 'Channel publicity succesfully saved'
          redirect_to trackings_path
        end
      else
        format.js
        format.html do
          flash[:error] = 'An error was occured when saving publicity'
          redirect_to trackings_path
        end
      end
    end
  end
end
