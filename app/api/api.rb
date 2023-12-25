class API < Grape::API
  prefix 'api'
  format :json
  mount Weather::API
  # add_swagger_documentation info: { title: 'grape-on-rails' }
end