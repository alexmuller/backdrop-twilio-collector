# Backdrop Twilio collector

Sinatra app that receives data from Twilio and puts it into [Backdrop][].

[Backdrop]: https://github.com/alphagov/backdrop

It runs on Heroku.

## Where it came from

This was a 2 day Christmas project that I worked on at the
[Government Digital Service][gds] at the end of 2013.

Backdrop is the data store and API behind the [Performance Platform][pp].

[gds]: http://digital.cabinetoffice.gov.uk
[pp]: https://www.gov.uk/performance

## How it works

My Twilio trial account provides a UK phone number that is set up to `POST`
to an endpoint I provide.

Twilio `POST`s to the endpoint inside this app (`/twilio/sms`) with details
of the SMS it has just received. This app processes the SMS, connects to
Backdrop and then sends a response (if the trial account has enough credit).

## Further development

- Add a "secret word" to the beginning of your SMS to act as basic authentication
- Move away from a single bucket (store multiple bucket names and tokens in a database)
