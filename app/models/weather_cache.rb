require 'net/http'

class WeatherCache < ApplicationRecord
  def self.cached_value
    # return '{"LocalObservationDateTime":"2023-12-24T15:22:00+03:00","EpochTime":1703420520,"WeatherText":"Cloudy","WeatherIcon":7,"HasPrecipitation":false,"IsDayTime":true,"Temperature":{"Metric":{"Value":-1.1,"Unit":"C","UnitType":17},"Imperial":{"Value":30.0,"Unit":"F","UnitType":18}},"MobileLink":"http://www.accuweather.com/en/ru/saint-petersburg/295212/current-weather/295212?lang=en-us","Link":"http://www.accuweather.com/en/ru/saint-petersburg/295212/current-weather/295212?lang=en-us"}'

    self.historical_values unless Rails.cache.read('historical_values')
    Rails.cache.read('historical_values')
  end

  def self.historical_values
    Rails.cache.fetch("historical_values", expires_in: 1.hours) do
      divider = '_'*80
      puts divider
      puts divider
      puts 'new request'
      # Net::HTTP.get('api.openweathermap.org',
      #   "/data/2.5/weather?lat=59.93&lon=30.33&appid=#{'20875e38959799c3621f5aab52f368d5'}")

      Net::HTTP.get('dataservice.accuweather.com', 
        "/currentconditions/v1/294021/historical/24?apikey=#{Rails.application.credentials.accuweather_api_key_for_andrewgavrick}")
    end
  end	

  def self.max
    JSON.parse(WeatherCache.cached_value).max { |a, b| a['Temperature']['Imperial']['Value'] <=> b['Temperature']['Metric']['Value']}
  end

  def self.min
    JSON.parse(WeatherCache.cached_value).min { |a, b| a['Temperature']['Imperial']['Value'] <=> b['Temperature']['Metric']['Value']}
  end

  def self.avg
    temperature_block = JSON.parse(WeatherCache.cached_value)[0]['Temperature']
    arr = JSON.parse(WeatherCache.cached_value) 
    temperature_block['Metric']['Value'] = arr.inject(0.0) { |sum, el| sum + el['Temperature']['Metric']['Value'] } / arr.size
    temperature_block['Imperial']['Value'] = arr.inject(0.0) { |sum, el| sum + el['Temperature']['Imperial']['Value'] } / arr.size
    temperature_block
  end

  def self.by_time(time)

    data = JSON.parse(WeatherCache.cached_value).sort {|a, b| a['EpochTime'] <=> b['EpochTime']}

    return nil unless data[0]['EpochTime']<time && time<data[-1]['EpochTime']
    data.each_with_index do |record, index|
      next if data[index + 1]['EpochTime'] > time

      return index + 1 if time * 2 > data[index]['EpochTime'] + data[index + 1]['EpochTime']
      return index
    end
    
  end


end
