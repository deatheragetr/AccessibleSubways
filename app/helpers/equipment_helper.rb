module EquipmentHelper
  def outage_return_blob
    Equipment.all.map { |equipment| as_blob(equipment) }.compact
  end

  def as_blob(equipment)
    outages = Rails.cache.fetch(equipment.equipment_no)
    unless outages.blank?
      {
        station_id: equipment.station_id,
        outages: outagify(outages)
      }
    end
  end

  def outagify(outages, equipment)
    outages.map do |outage|
      {
        serving:  outage['serving'],
        equipment_type: outage['equipmenttype'],
        routes_affected: equipment.find_by(equipement_num: outage['equipment']),
        reason: outage['reason'],
        outage_start_date: DateTime.strptime(outage['outagedate'], '%m/%d/%Y %l:%M:%S %p'),
        estimated_return_of_service: DateTime.strptime(outage['esitmated_return_to_service'], '%m/%d/%Y %l:%M:%S %p'),
        ada: ourtage['ADA']
      }
    end
  end
end
