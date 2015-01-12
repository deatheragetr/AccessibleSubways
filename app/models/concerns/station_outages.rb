# equipment_url = "http://advisory.mtanyct.info/eedevwebsvc/allequipments.aspx"

module StationOutages
  def self.get_outages
    xml_feed = HTTParty.get('http://web.mta.info/developers/data/nyct/nyct_ene.xml')
    outages = xml_feed['NYCOutages']['outage']

    outages.each do |outage|
      station_routes = outage['trainno'].match(/(\w{1})\//)
    end
  end
end