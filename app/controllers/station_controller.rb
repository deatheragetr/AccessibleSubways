class StationController < ApplicationController

  def stations
    render :json => Station.all
  end
end


