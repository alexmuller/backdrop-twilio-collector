require 'sinatra'
require 'twilio-ruby'
require 'date'
require 'json'

# Ugh, Foreman.
$stdout.sync = true

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
  puts datum.to_json

  # Blank TwiML response
  Twilio::TwiML::Response.new.text
end

post '/twilio/voice' do
  # Why are you phoning me?
  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello from the Government Digital Service. Try texting me instead.', :voice => 'en-gb'
  end.text
end
