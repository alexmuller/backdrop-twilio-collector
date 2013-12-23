require 'sinatra'
require 'twilio-ruby'

@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

get '/' do
  "backdrop-twilio-collector is up and running."
end

get '/twilio/sms' do
  "200 OK"
end
