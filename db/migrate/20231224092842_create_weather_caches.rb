class CreateWeatherCaches < ActiveRecord::Migration[7.1]
  def change
    create_table :weather_caches do |t|

      t.timestamps
    end
  end
end
