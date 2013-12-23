# Backdrop Twilio collector

Sinatra app that receives data from Twilio and puts it into [Backdrop][].

[Backdrop]: https://github.com/alphagov/backdrop

Runs on Heroku.

## Environment variables

    ENV['BACKDROP_BUCKET'] = bucket_name
    ENV['BACKDROP_TOKEN'] = bucket_bearer_token
    ENV['TWILIO_ACCOUNT_SID'] = twilio_account_sid
    ENV['TWILIO_AUTH_TOKEN'] = twilio_auth_token
