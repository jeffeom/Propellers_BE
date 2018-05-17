#1
require 'sinatra'
require 'stripe'
require 'json'
require './key' if File.exists?('key.rb')

Stripe.api_key = ENV['test_key']

class PropellerWeb < Sinatra::Base
  get '/' do
    status 200
    return "Propellers backend has been set up correctly"
  end

  post '/charge' do
    authenticate!
    # Get the credit card details submitted
    payload = params
    if request.content_type.include? 'application/json' and params.empty?
      payload = indifferent_params(JSON.parse(request.body.read))
    end

    source = payload[:token]
    customer = payload[:customer_id] || @customer.id
    # Create the charge on Stripe's servers - this will charge the user's card

    begin
      charge = Stripe::Charge.create(
        :amount => payload[:amount],
        :currency => payload[:currency],
        :customer => customer,
        # :source => source,
        :description => payload[:description]
      )
      rescue Stripe::StripeError => e
      status 402
      return "Error creating charge: #{e.message}"
    end
    status 200
    return "Charge successfully created"
  end

  def authenticate!
    return @customer if @customer
    if session.has_key?(:customer_id)
      customer_id = session[:customer_id]
      begin
        @customer = Stripe::Customer.retrieve(customer_id)
      rescue Stripe::InvalidRequestError
      end
    else
      begin
        @customer = Stripe::Customer.create(
          :email => session[:email],
          :source => session[:token]
        )
      rescue Stripe::InvalidRequestError
      end
      session[:customer_id] = @customer.id
    end
    @customer
  end
end
