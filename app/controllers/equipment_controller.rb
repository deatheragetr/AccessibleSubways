class EquipmentController < ApplicationController
  include EquipmentHelper

  def outages
    render :json => outage_return_blob
  end
end
