module EquipmentHelper
  def outage_return_blob(opts = {})
    equipment_list = opts[:station_ids] ? Equipment.where('station_id in (?)', opts[:station_ids]) : Equipment.all
    equipment_list.map { |equipment| as_blob(equipment) }.compact
  end

  def as_blob(equipment)
    outages = Rails.cache.fetch(equipment.equipment_no)
    unless outages.blank?
      {
        station_id: equipment.station_id,
        outages: outagify(outages, equipment)
      }
    end
  end

  def outagify(outages, equipment)
    outages.map do |outage|
      {
        station_id: equipment.station_id,
        serving:  outage['serving'],
        equipment_type: outage['equipmenttype'],
        equipment_no: equipment.equipment_no,
        routes_affected: equipment.routes,
        reason: outage['reason'],
        outage_start_date: DateTime.strptime(outage['outagedate'], '%m/%d/%Y %l:%M:%S %p'),
        estimated_return_of_service: DateTime.strptime(outage['estimatedreturntoservice'], '%m/%d/%Y %l:%M:%S %p'),
        ada: outage['ADA']
      }
    end
  end
end
