# omniauth_sinatra

Small app to help run and debug omniauth strategies locally with the help of a sinatra app

## Setup (could vary between platforms)
* Set up an app via the platform's settings.
* Set the `redirect_url` or `callback_url` to `http://localhost:9292/auth/<platform>/callback`, replacing `<platform>` with the name defined in `my_sinatra_app.rb`
* Obtain the `CLIENT_ID`, `CLIENT_SECRET`, and any other pieces of info required from platform.


## Running the OmniAuth Sinatra app
* run `bundle`
* Set `CLIENT_ID` AND `CLIENT_SECRET` in ENV variables for specific platform (see my_sinatra_app.rb for specific names for variables)
* run `rackup`
* Load page up in browser (http://localhost:9292)
* Click link to the platform you're testing
* Get redirected to platform's login page, log in
* Accept permissions to access scopes defined in Omniauth provider
* Get redirected back to your callback url
* Auth info is put into your terminal for you to use to then authenticate your actual requests

