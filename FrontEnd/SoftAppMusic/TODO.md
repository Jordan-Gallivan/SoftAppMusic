#  TODO List
    

Today:
x display TOS to user before account creation -> After account created, before login
o user profile:
    x if create user -> set spotifyConsent to True
    o Required Fields -> age
    x add "updateSpotifyCredentials" call
x workoutPrompt: 
    x implement validation of spotify credentials
        if !spotifyConsent -> display spotify SpotifyLogin
    x implement functionality to just pull user preferences from appData
x SpotifyCredentialsView
x add updateSpotifyCredentials() to fetchUserData

o add refresh button for error page
    o add closure to error view 

x get music preferences working -> incorrect format on BE

