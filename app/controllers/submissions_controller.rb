class SubmissionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :verify_parameters, :verify_network, :verify_client_key, :get_channel, :verify_tracking

  def create
    Delayed::Job.enqueue Submission.new(
      :url => params[:url],
      :nick => params[:nick],
      :ident => params[:mask].split('@', 2).first,
      :host => params[:mask].split('@', 2)[1],
      :sent_at => Time.now,
      :sent_from => request.env['REMOTE_ADDR'],
      :tracking_id => @tracking.id
    )
    render(:nothing => true)
  end

  private

  def verify_tracking
    @tracking = (
      @user.trackings.find_by_channel_id(@channel.id) ||
      @user.trackings.create(:channel => @channel, :publicity => nil)
    )

    render :text => "Channel is not tracked", :status => 400 and return false unless @tracking.publicity
  end

  def get_channel
    @channel = (
      @network.channels.slugified(:name, params[:channel]).first ||
      @network.channels.create!(:name => params[:channel], :status => nil)
    )
  end

  # Verify that mask, nick and url parameters exist
  def verify_parameters
    # TODO: rails 3 and activemodel validation
    parts = (params[:mask].to_s.split('@', 2) + [params[:nick], params[:url]])
    if parts.length != 4 || params.any?(&:blank?)
      render :text => "Invalid submission", :status => 400
      return false
    end
  end

  def verify_network
    @network = Network.slugified(:name, params[:network]).first
    render :text => "Unknown network", :status => 404 and return false unless @network
  end

  def verify_client_key
    @user = User.find_by_client_key(params[:client_key])
    render :text => "Invalid client key", :status => :forbidden and return false unless @user
  end
end
