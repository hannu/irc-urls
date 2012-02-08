class ChannelsController < ApplicationController
  before_filter :get_channel, :except => [:index]
  
  def show
  end

  def index
    @network = Network.find_by_name(params[:network_id])
    @channels = @network.channels
  end

  private
    def get_channel
      @channel = Network.find_by_name(params[:network_id]).channels.slugified(:name, params[:id]).first
    end
end
