#  TODO List
    
o Validate spotify credentials upon login!
o Spotify Conset/username password
o refresh buttons/pull down?
o xn from create user profile to fetching music preferences.  Add "initial user creation to init"?

Today:
x display TOS to user before account creation -> After account created, before login
o user profile:
    x if create user -> set spotifyConsent to True
    o Required Fields -> age
    x add "updateSpotifyCredentials" call
o workoutPrompt: 
    x implement validation of spotify credentials
        if !spotifyConsent -> display spotify SpotifyLogin
    x implement functionality to just pull user preferences from appData
x SpotifyCredentialsView
x add updateSpotifyCredentials() to fetchUserData
o spoftify credentials view:
    o padding above username field
    o save button
o add refresh button for error page
    o add closure to error view 


Tuesday discussion Items:
o spotify credential endpoint
    /user_profile_data/{email}/spotify_credentials
o handling the "spotifyConsent" attribute
    - if credentials work? -> keep true
    - else -> set to false, user will be prompted again to add credentials
o WebSocket
    - initial request:
        -> initial GET
        <- {url: $websocketURL }
    - integer HR data every second
    - threshold tripped?
        <- {"recommendation": Int,        
            "suggestion": fast || slow }
        -> {"recommendation": Int,
            "accept": Bool }
