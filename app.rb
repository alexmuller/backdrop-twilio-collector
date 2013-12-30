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

SECRET_WORD = ENV['SECRET_WORD']

TWILIO_CLIENT = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
TWILIO_NUMBER = ENV['TWILIO_NUMBER']

def send_sms(body, to)
  TWILIO_CLIENT.account.messages.create(
    :body => body,
    :to => to,
    :from => TWILIO_NUMBER
  )
end

get '/' do
  "backdrop-twilio-collector is up and running."
end

post '/twilio/sms' do
  # Process SMS request
  if not params['From'] or not params['Body']
    send_sms("We couldn't see who this SMS was from or what the body was", params['From'])
    halt 400
  end
  secret_word, special_number = params['Body'].split(' ')
  # Make sure they know the sooper seekret password
  if secret_word != SECRET_WORD
    send_sms('Your secret word was wrong. Oops!', params['From'])
    halt 400
  end
  # Parse the number as an integer or fail
  begin
    value = Integer(special_number)
  rescue ArgumentError => e
    random_integer = 1 + rand(1000)
    send_sms("It doesn't look like you sent a number :/. Try just '#{random_integer}' in a new text.", params['From'])
    halt 400
  end

  datum = {
    sender_number: params['From'],
    value: value,
    data_source: 'twilio',
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
      send_sms("Received your number and stored it. Thanks!", datum[:sender_number])
      halt 200, Twilio::TwiML::Response.new.text
    else
      # Something went wrong with the Backdrop request
      send_sms("We had an issue with the request to Backdrop :(", datum[:sender_number])
      halt 500
    end
  end

  request.run

  # If we've made it down here something's gone wrong
  send_sms("Something's gone *really* wrong :'(", datum[:sender_number])
  halt 500
end

post '/twilio/voice' do
  # Why are you phoning me?
  Twilio::TwiML::Response.new do |r|
    r.Say 'Hello from the Government Digital Service. Try texting me instead.', :language => 'en-gb'
  end.text
end
