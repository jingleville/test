require 'net/http'

module Weather
  class API < Grape::API
    version 'v1', using: :header, vendor: 'weather'
    prefix 'api'
    format :json

    resource :weather do
      desc 'Returns current weather'
      get :current do
        JSON.parse(WeatherCache.cached_value)[0]
      end

      resource :by_time do
        desc 'Returns weather readings by time'
        params do
          requires :time, type: Integer, desc: "Timestamp of required weather data"
        end
        route_param :time do
          get do
            res = WeatherCache.by_time(params[:time])
            if res
              JSON.parse(WeatherCache.cached_value)[WeatherCache.by_time(params[:time])]
            else
              status 404
            end
          end
        end
      end

      desc 'Returns historical readings'
      resource :historical do

        desc 'Returns all historical readings in 24 hours'
        get :/ do
          JSON.parse(WeatherCache.cached_value)
        end

        desc 'Returns max temperature in 24 hours'
        get :max do
          WeatherCache.max
        end

        desc 'Returns min temperature in 24 hours'
        get :min do
          WeatherCache.min
        end

        desc 'Returns avg temperature in 24 hours'
        get :avg do
          WeatherCache.avg
        end

      end
    end

    desc 'Returns server status'
    get :health do
      status 200
    end
  end
end