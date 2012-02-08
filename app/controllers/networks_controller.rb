class NetworksController < ApplicationController
  before_filter :get_network, :except => [:index]
  
  def show
  end

  def index
    @networks = Network.all(
      :order => "#{Network.table_name}.name ASC"
    )
  end

  private
    def get_network
      @network = Network.slugified(:name, params[:id]).first
    end
end
