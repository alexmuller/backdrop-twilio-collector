require 'sinatra'
require 'twilio-ruby'
require 'date'
require 'json'
require 'typhoeus'

# Ugh, Foreman.
$stdout.sync = true

BACKDROP_HOST = ENV['BACKDROP_HOST']
BACKDROP_BUCKET = ENV['BACKDROP_BUCKET']
BACKDROP_TOKEN = ENV['BACKDROP_TOKEN']

TWILIO_CLIENT = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
TWILIO_NUMBER = ENV['TWILIO_NUMBER']

get '/' do
  "backdrop-twilio-collector is up and running."
end

post '/twilio/sms' do
  # Process SMS request
  if not params['From'] or not params['Body']
    halt 400
  end
  # Parse the body as an integer or fail
  begin
    value = Integer(params['Body'])
  rescue ArgumentError => e
    halt 400
  end

  datum = {
    sender_number: params['From'],
    value: value,
    _timestamp: DateTime.now.iso8601
  }

  # Send datum to backdrop
  request = Typhoeus::Request.new(
    "https://#{BACKDROP_HOST}/#{BACKDROP_BUCKET}",
    method: :post,
    headers: {
      'Authorization' => "Bearer #{BACKDROP_TOKEN}",
      'Content-type' => 'application/json'
    },
    body: datum.to_json
  )

  request.on_complete do |response|
    if response.success?
      # Blank TwiML response
      TWILIO_CLIENT.account.messages.create(
        :body => "Received your number and stored it. Thanks!",
        :to => datum[:sender_number],
        :from => TWILIO_NUMBER
      )
      halt 200, Twilio::TwiML::Response.new.text
    else
      # Something went wrong with the Backdrop request
      halt 500
    end
  end

  request.run

  # If we've made it down here something's gone wrong
  halt 500
end

post '/twilio/voice' do
  # Why are you phoning me?
  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello from the Government Digital Service. Try texting me instead.', :language => 'en-gb'
  end.text
end
