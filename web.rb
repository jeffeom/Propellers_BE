#1
require 'sinatra'
require 'stripe'
require 'json'

Stripe.api_key = ENV['test_key']

class PropellerWeb < Sinatra::Base
  get '/' do
    status 200
    return "Propellers backend has been set up correctly"
  end

  post '/charge' do
    payload = params
    if request.content_type.include? 'application/json' and params.empty?
      payload = indifferent_params(JSON.parse(request.body.read))
    end

    begin
      charge = Stripe::Charge.create(
        :amount => payload[:amount],
        :currency => payload[:currency],
        :source => payload[:token],
        :description => payload[:description]
      )
      rescue Stripe::StripeError => e
      status 402
      return "Error creating charge: #{e.message}"
    end
    status 200
    return "Charge successfully created"
  end
end
