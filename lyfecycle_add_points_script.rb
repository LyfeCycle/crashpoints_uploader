require 'roo'
require 'httparty'
require 'geocoder'
require 'pry'

base_uri = 'http://lyfecycle-api.herokuapp.com/locations'

# reset the database (TESTING ONLY)
###################################puts HTTParty.post(base_uri + '/reset', :headers => { 'Content-Type' => 'application/json' })

# open spreadsheet
spreadsheet = Roo::Spreadsheet.open("./bike-collision-database.xlsx")
end_row = 1805

# init the json for each new location
point = {name: 'Boston Crash Point'}

# loop through each row
spreadsheet.sheet(0).each_with_index(address: 'Address', doored: 'Doored', area: 'PlanningDi') do |row, index|
    break if index == end_row
    next if !row[:address] # skip if there's no address
    # look up coordinates
    location = Geocoder.search("#{row[:address]} #{row[:area]} MA").first.data['geometry']['location']
    # construct the json for the new location
    point[:longitude] = location['lng'].to_s
    point[:latitude] = location['lat'].to_s
    point[:tag] = (row[:doored].to_i==1) ? "dooring" : "crash"
    # add to database
    puts HTTParty.post(base_uri, 
      :body => point.to_json, 
      :headers => { 'Content-Type' => 'application/json' }
    )
    # wait a little to avoid the geocoder limit
    sleep(1)
end