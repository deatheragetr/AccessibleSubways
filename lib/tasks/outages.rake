namespace :outages do
  OUTAGES_URL = 'http://web.mta.info/developers/data/nyct/nyct_ene.xml'

  task :poll => :environment do
    xml_feed = HTTParty.get(OUTAGES_URL)
    outages = xml_feed['NYCOutages']['outage']

    Rails.cache.clear

    outages.each do |outage|
      cached_outages = Rails.cache.fetch(outage['equipment']) || []
      cached_outages << outage
      Rails.cache.write(outage['equipment'], cached_outages)
    end
  end
end