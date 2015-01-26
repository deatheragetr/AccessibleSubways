class EquipmentController < ApplicationController
  include EquipmentHelper

  def outages
    station_ids = params[:station_ids].gsub(/\[|\]/, '').split(',').collect(&:strip).map(&:to_i) unless params[:station_ids].blank?
    render :json => outage_return_blob(station_ids: station_ids)
  end
end
