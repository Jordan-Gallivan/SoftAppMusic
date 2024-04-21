require('dotenv').config({path: 'urls.env'});
const PORT = process.env.PORT;
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");
const express = require("express");
const app = express();
require('express-ws')(app);
const cors = require("cors");
const bcrypt = require("bcryptjs");
const axios = require("axios");
const saltRounds = 10;
const JWT_SECRET = 'secret';
const querystring = require('querystring')
const MONGO_URL = process.env.MONGO_URL;
const SPOTIFY_CLIENT_ID = process.env.SPOTIFY_CLIENT_ID;
const SPOTIFY_SECRET = process.env.SPOTIFY_SECRET;
const crypto = require('crypto');
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY
const IV_LENGTH = 16;

app.use(express.json());
app.use(cors());

mongoose.connect(MONGO_URL)
    .then(() => console.log('Much Success'))
    .catch(err => console.error('MongoDB bad', err))

app.get("/", (req, res) => {
    res.send("Express App is Running")
})

const Users = mongoose.model('users', {
    email: {
        type: String,
        unique: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    firstName: {
        type: String,
    },
    lastName: {
        type: String,
    },
    age: {
        type: Number
    },
    spotifyConsent: {
        type: Boolean
    },
    workoutPreferences: {
        type: Map,
        of: [String]
    },
    spotifyCredentials: {
        accessToken: {
            type: String
        },
        refreshToken: {
            type: String
        },
        expiresOn: {
            type: Date
        },
        scope: {
            type: String
        }
    }
})

function encrypt(text) {
    if (typeof text !== 'string') {
        throw new TypeError('Text must be a string');
    }

    if (!ENCRYPTION_KEY) {
        throw new Error('Encryption key is not set or not valid');
    }

    const iv = crypto.randomBytes(IV_LENGTH);
    let cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY, 'hex'), iv);
    let encrypted = cipher.update(Buffer.from(text));

    encrypted = Buffer.concat([encrypted, cipher.final()]);
    return iv.toString('hex') + ':' + encrypted.toString('hex');
}

function decrypt(text) {
    if (typeof text !== 'string') {
        throw new TypeError('Text must be a string');
    }

    let textParts = text.split(':');
    if (textParts.length !== 2) {
        throw new Error('Invalid input text. Text must be a valid encrypted string with an IV.');
    }

    let ivString = textParts.shift();
    let encryptedTextString = textParts.join(':');

    if (!ivString || !encryptedTextString) {
        throw new Error('Invalid input text. IV or encrypted string is missing.');
    }

    let iv = Buffer.from(ivString, 'hex');
    let encryptedText = Buffer.from(encryptedTextString, 'hex');
    let decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(ENCRYPTION_KEY, 'hex'), iv);

    let decrypted;
    try {
        decrypted = decipher.update(encryptedText);
        decrypted = Buffer.concat([decrypted, decipher.final()]);
    } catch (err) {
        throw new Error('Decryption failed: ' + err.message);
    }

    return decrypted.toString();
}

app.get('/music_types', async (req, res) => {
    try {
        const musicTypes = ["rock", "pop", "metalcore", "punk-rock", "country", "hip-hop", "edm"];
        res.json(musicTypes);

    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error")
    }
})

app.get('/workout_types', async (req, res) => {
    try {
        const workoutTypes = ["HIIT", "Tempo Run", "Long Run", "WeightLifting"]
        res.json(workoutTypes);

    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error")
    }
})

app.post('/login', async (req, res) => {
    try {

        const user = await Users.findOne({email: {$regex: req.body.username, $options: 'i'}});
        if (!user) {
            return res.status(400).json({success: false, errors: "There is no account with that email registered"});
        }

        const isMatch = await bcrypt.compare(req.body.password, user.password);
        if (!isMatch) {
            return res.status(401).json({success: false, errors: "That email and password do not match"});
        }

        const data = {user: {id: user.id}};
        const token = jwt.sign(data, JWT_SECRET);
        console.log(user.email + " logged in");
        res.json({success: true, token});
    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
    }
});

app.post('/create_user_login', async (req, res) => {
    try {
        const existingUser = await Users.findOne({email: req.body.username});
        if (existingUser) {
            return res.status(409).json({success: false, errors: "Existing user found with that email"});
        }

        const hashedPassword = await bcrypt.hash(req.body.password, saltRounds);
        const user = new Users({
            email: req.body.username,
            password: hashedPassword,
        });

        await user.save();
        res.status(201).send({message: "User created successfully"});
    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
    }
});

function authenticateUser(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token)
        return res.status(401).send({errors: "No token"})

    else {
        try {
            const data = jwt.verify(token, JWT_SECRET);
            req.user = data.user;
            next();
        } catch (error) {
            res.status(401).send({errors: "Please authenticate using a valid token"})
        }
    }
}

app.get('/user_profile/:email', authenticateUser, async (req, res) => {
    try {
        let user;
        user = await Users.findOne({_id: req.user.id})
        if (!user) {
            return res.status(409).send({errors: "User not found"})
        }

        const userData = {
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            age: user.age,
            spotifyConsent: user.spotifyConsent
        };

        res.json(userData);
    } catch (error) {
        console.error(error)
        res.status(500).json({message: "Internal Server Error"});
    }
})

app.post('/user_profile/:email', authenticateUser, async (req, res) => {
    try {
        let user;
        user = await Users.findOne({_id: req.user.id})
        if (!user) {
            return res.status(409).send({errors: "User not found"})
        } else {
            user.email = req.body.email
            user.firstName = req.body.firstName;
            user.lastName = req.body.lastName;
            user.age = req.body.age;
            user.spotifyConsent = req.body.spotifyConsent;

            await user.save();
            res.status(201).send({message: "User profile updated successfully"});
        }


    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
    }
})

app.get('/user_profile/:email/music_preferences', authenticateUser, async (req, res) => {
    try {
        let user;
        user = await Users.findOne({_id: req.user.id})
        if (!user) {
            return res.status(409).send({errors: "User not found"})
        }

        const workoutPreferences = {};
        for (let [key, value] of user.workoutPreferences.entries()) {
            workoutPreferences[key] = value;
        }
        res.json({workoutPreferences});

    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
    }
})

app.post('/user_profile/:email/music_preferences', authenticateUser, async (req, res) => {
    try {
        let user;
        user = await Users.findOne({_id: req.user.id})
        if (!user) {
            return res.status(409).send({errors: "User not found"})
        } else {
            user.workoutPreferences = new Map(Object.entries(req.body));
            await user.save();
            res.status(201).send({message: "User preferences updated successfully"});
        }

    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
    }
})

app.ws('/init_session/:email', async function (ws, req) {
    const email = req.params.email
    console.log('Client connected with email: ', email);

    const parsedUrl = new URL(req.url, `https://${req.headers.host}`);
    const wsToken = parsedUrl.searchParams.get('token');

    if (!validateTemporaryToken(wsToken)) {
        ws.close(1008, "Policy Violation");
    }
    let user
    user = await Users.findOne({email: email})
    const accessToken = await getAccessToken(user.email);
    let currentWorkoutType;
    let currentMusicType;
    let lowSuggestions = [];
    let highSuggestions = [];
    //let workingSuggestions = [];
    let currentSongLength = 0;
    let songTimer;
    let lowIndex = 0
    let highIndex = 0;
    let index = 0
    let canProcessHeartRate = false
    let heartRateTimer = null;
    let canPlayHigh = false
    let canPlayLow = true
    let currentHeartRateZone = null
    let timerStarted = false;
    let lastWorkoutZone = null;
    let currentWorkoutZone = null;

    ws.send(JSON.stringify({request: 0, message: 'success'}))

    const heartRateZones = {
        HIGH: 90,
        LOW: 70,
        WORKING: (220 - user.age) * 0.8
    }

    const pendingResponses = new Map();

    function sendRequest(ws, data) {
        console.log("Sending playlist request")
        return new Promise((resolve, reject) => {
            const requestIndex = data.request;
            pendingResponses.set(requestIndex, { resolve, reject });
            ws.send(JSON.stringify(data))

            setTimeout(() => {
                if(pendingResponses.has(requestIndex)) {
                    console.log("No response received, automatically accepting changes.");
                    resolve('Automatically Accepted')
                    pendingResponses.delete(requestIndex);
                }
            }, 15000);
        })
    }

    ws.on('message', async function (msg) {

        try {
            const {workoutType, musicType, heartRate, request, message} = JSON.parse(msg)

            if (workoutType && musicType) {

                currentWorkoutType = workoutType
                currentMusicType = musicType;
                console.log("Music Type: ", musicType);
                console.log("Workout Type: ", workoutType);
                const timeRemaining = await getCurrentPlayback(accessToken)
                console.log("Getting low threshold suggestions")
                const result = await initializeWorkout(accessToken, musicType, 'low', lowIndex, timeRemaining)
                currentHeartRateZone = 'LOW'
                currentWorkoutZone = 'LOW'
                index++

                if (result) {
                    lowSuggestions = result.musicSuggestions
                    currentSongLength = result.currentSongLength
                    songTimer = result.songTimer
                    lowIndex = result.index
                }
                console.log("Getting high threshold suggestions");
                highSuggestions = await determineMusicSuggestions(accessToken, currentMusicType, 'high');
                //console.log("Getting working threshold suggestions");
                //await determineMusicSuggestions(accessToken, currentMusicType, 'working');

                setTimeout(() => {
                    canProcessHeartRate = true;
                    console.log("Now processing heart rate data")
                }, 5000)

            } else if (request !== undefined && message === 'accept' || message === 'reject') {
                if(pendingResponses.has(request)) {
                    const { resolve, reject } = pendingResponses.get(request);

                    if(message === 'accept') {
                        console.log('Changes explicitly accepted');
                        resolve('Explicitly Accepted')
                    } else {
                        console.log("Changes explicitly not accepted");
                        reject(new Error('Changes explicitly not accepted'));
                    }
                    pendingResponses.delete(request);
                }

            } else if (heartRate && canProcessHeartRate) {

                if(currentWorkoutZone !== lastWorkoutZone) {
                    console.log("Resetting timer");
                    lastWorkoutZone = currentWorkoutZone;
                    heartRateTimer = null;
                    timerStarted = false;
                }

                if(heartRate < heartRateZones.LOW) {
                    currentWorkoutZone = 'LOW'
                    if(currentHeartRateZone !== 'LOW' && !timerStarted) {
                        console.log("Low Threshold reached, starting timer")
                        heartRateTimer = Date.now();
                        timerStarted = true;
                    }
                } else if (heartRate > heartRateZones.HIGH) {
                    currentWorkoutZone = 'HIGH'
                    if(currentHeartRateZone !== 'HIGH' && !timerStarted) {
                        console.log("High Threshold reached, starting timer")
                        heartRateTimer = Date.now();
                        timerStarted = true;
                    }
                }

                if(Date.now() - heartRateTimer > 20000 && timerStarted) {
                    timerStarted = false;
                    if (heartRate > heartRateZones.HIGH) {
                        sendRequest(ws, {request: index, message: 'fast'})
                            .then(async result => {
                                canPlayHigh = true;
                                canPlayLow = false;
                                currentHeartRateZone = 'HIGH'
                                heartRateTimer = null;
                                console.log('Request accepted:', result)
                                console.log(`Adding ${highSuggestions[highIndex].name} to queue`)
                                await addSongToQueue(highSuggestions[highIndex].uri, accessToken);
                                index++
                                highIndex++

                            })
                            .catch(error => {
                                canPlayHigh = false;
                                canPlayHigh = true;
                                currentHeartRateZone = 'LOW'
                                heartRateTimer = null
                                timerStarted = false;
                                console.error('Request rejected or failed:', error)
                            })
                    } else {
                        sendRequest(ws, {request: index, message: 'slow'})
                            .then(async result => {
                                canPlayHigh = false;
                                canPlayLow = true;
                                currentHeartRateZone = 'LOW'
                                heartRateTimer = null
                                console.log('Request accepted:', result)
                                console.log(`Adding ${lowSuggestions[lowIndex].name} to queue`)
                                await addSongToQueue(lowSuggestions[lowIndex].uri, accessToken);
                                index++
                                lowIndex++
                            })
                            .catch(error => {
                                canPlayHigh = true;
                                canPlayLow = false;
                                currentHeartRateZone = 'HIGH'
                                heartRateTimer = null
                                timerStarted = false;
                                console.error('Request rejected or failed:', error)
                            })
                    }
                }

                switch (currentWorkoutType) {
                    case 'HIIT':
                        if(!canPlayHigh) {
                            if (currentSongLength - (Date.now() - songTimer) < 30000) {
                                if (lowIndex < lowSuggestions.length) {
                                    console.log(`Adding ${lowSuggestions[lowIndex].name} to queue`)
                                    currentSongLength = lowSuggestions[lowIndex].duration_ms
                                    songTimer = Date.now() + 30000;
                                    await addSongToQueue(lowSuggestions[lowIndex].uri, accessToken);
                                    lowIndex++
                                    index++
                                } else {
                                    console.log('Fetching more songs')
                                    const result = await initializeWorkout(accessToken, musicType, 'low', 0, Date.now + 30000)

                                    if (result) {
                                        lowSuggestions = result.musicSuggestions
                                        currentSongLength = result.currentSongLength
                                        songTimer = result.songTimer
                                        lowIndex = result.index
                                    }
                                    index++
                                }
                            }
                        }
                        if(!canPlayLow) {
                            if (currentSongLength - (Date.now() - songTimer) < 30000) {
                                if (highIndex < lowSuggestions.length) {
                                    console.log(`Adding ${highSuggestions[highIndex].name} to queue`)
                                    currentSongLength = highSuggestions[highIndex].duration_ms
                                    songTimer = Date.now() + 30000;
                                    await addSongToQueue(highSuggestions[highIndex].uri, accessToken);
                                    highIndex++
                                    index++
                                } else {
                                    console.log('Fetching more songs')
                                    const result = await initializeWorkout(accessToken, musicType, 'low', 0, Date.now + 30000)

                                    if (result) {
                                        highSuggestions = result.musicSuggestions
                                        currentSongLength = result.currentSongLength
                                        songTimer = result.songTimer
                                        highIndex = result.index
                                    }
                                    index++
                                }
                            }
                        }
                        break;
                }
            }
        } catch (error) {

        }
    });

    ws.on('close', function (code, reason) {
        console.log(`WebSocket closed with code: ${code}, reason: ${reason}`);
    })

    ws.on('error', function (error) {
        console.error('WebSocket error: ', error);
    })
});

async function initializeWorkout(accessToken, musicType, heartRate, index, timeRemaining) {
    let suggestions = await determineMusicSuggestions(accessToken, musicType, heartRate);


    if (suggestions.length > 0) {
        let currentSongLength = suggestions[index].duration_ms + timeRemaining
        let songTimer = Date.now()
        console.log("Adding " + suggestions[0].name + " to queue")
        await addSongToQueue(suggestions[0].uri, accessToken)

        return {
            musicSuggestions: suggestions,
            currentSongLength: currentSongLength,
            songTimer: songTimer,
            index: index + 1,
        };
    }
}

function validateTemporaryToken(token) {
    if (!token) {
        console.error('Token is missing');
        return false
    }
    try {
        jwt.verify(token, JWT_SECRET);
        return true;
    } catch (error) {
        console.error('Token validation error:', error.message);
        return false;
    }
}

async function determineMusicSuggestions(accessToken, musicType, heartRate) {
    const recommendationURL = 'https://api.spotify.com/v1/recommendations'
    let targetDanceability;
    let targetEnergy;

    if(heartRate === 'working') {
        targetDanceability = 0.7
        targetEnergy = 0.7
    } else if (heartRate === 'low') {
        targetDanceability = 0.3
        targetEnergy = 0.3
    } else if (heartRate === 'high') {
        targetDanceability = 0.9
        targetEnergy = 0.8
    }
    try {
        const response = await axios.get(recommendationURL, {
            params: {
                seed_genres: musicType,
                target_danceability: targetDanceability,
                target_energy: targetEnergy
            },
            headers: {
                'Authorization': `Bearer ${accessToken}`,
            }
        });

        if (response.data && response.data.tracks) {
            const suggestions = response.data.tracks
            console.log('Tracks fetched successfully');
            suggestions.forEach((track, index) => {
                let artistNames = track.artists.map(artist => artist.name).join(", ");
                console.log(`Song ${index + 1}: ${track.name} by ${artistNames}`);
            });
            return response.data.tracks
        }
    } catch (error) {
        console.log(error.errors)
    }
}

async function addSongToQueue(songUri, accessToken) {
    try {
        const response = await axios.post(`https://api.spotify.com/v1/me/player/queue?uri=${encodeURIComponent(songUri)}`, {}, {
            headers: {
                'Authorization': `Bearer ${accessToken}`,
            }
        });
        if (response.status === 204) {
            console.log('Track added to the queue successfully');
        } else {
            console.log('Something went wrong', response);
        }
    } catch (error) {
        console.log("Failed: " + error + error.message)
    }
}

app.get('/init_session/:email/auth', authenticateUser, async (req, res) => {
    try {
        let user;
        user = await Users.findOne({_id: req.user.id})
        if (!user) {
            console.log('User not found');
            return
        }
        const wsToken = generateTemporaryToken(user);
        res.json({wsToken})
    } catch (error) {
        console.error(error);
        res.status(500).send("Internal Server Error");
    }
})

function generateTemporaryToken(user) {
    const data = {user: {id: user.id}};
    return jwt.sign(data, JWT_SECRET, {expiresIn: '5m'});
}

app.post('/user_profile/:email/spotify_credentials', authenticateUser, async (req, res) => {
    const {code} = req.body;
    let user;
    user = await Users.findOne({_id: req.user.id})

    if (!user) {
        return res.status(409).send({errors: "User not found"})
    }

    const clientId = SPOTIFY_CLIENT_ID;
    const clientSecret = SPOTIFY_SECRET;
    const redirectUri = "softAppSpring2024://callback";

    const tokenResponse = await axios.post('https://accounts.spotify.com/api/token', querystring.stringify({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: redirectUri,
    }), {
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic ' + Buffer.from(`${clientId}:${clientSecret}`).toString('base64')
        },
    }).catch(error => {
        console.error('Failed to exchange code for tokens', error.response.data);
        return res.status(500).json({error: 'Failed to exchange code for tokens'});
    });

    if (tokenResponse && tokenResponse.data) {
        console.log("Got access token")
        const {access_token, refresh_token, expires_in, scope} = tokenResponse.data
        user.spotifyCredentials.accessToken = encrypt(access_token)
        user.spotifyCredentials.refreshToken = encrypt(refresh_token);
        user.spotifyCredentials.expiresOn = Date.now() + (expires_in * 1000);
        user.spotifyCredentials.scope = scope
        user.spotifyConsent = true;
        await user.save();
        res.status(201).send({message: "User token data stored successfully"});
    } else {
        user.spotifyConsent = false;
        await user.save();
    }
});

async function refreshAccessToken(refreshToken) {
    console.log("Token expired, getting a new one")
    try {

        const res = await axios.post('https://accounts.spotify.com/api/token', querystring.stringify({
            grant_type: 'refresh_token',
            refresh_token: refreshToken,
        }), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': 'Basic ' + Buffer.from(`${SPOTIFY_CLIENT_ID}:${SPOTIFY_SECRET}`).toString('base64')
            },
        });
        const {access_token, expires_in} = res.data;
        console.log("Refreshed token")
        return {
            accessToken: access_token,
            expiresIn: expires_in
        };

    } catch (error) {
        console.error('Failed to refresh Spotify access token:', error);
        throw new Error('Failed to refresh access token');
    }
}

async function getAccessToken(email) {
    console.log("Attempting to get token")
    let user;
    user = await Users.findOne({email: email});
    const {accessToken, refreshToken, expiresOn} = user.spotifyCredentials;

    try {
        if (Date.now() > expiresOn) {
            console.log('Date.now > expires On');
            const refreshedToken = await refreshAccessToken(decrypt(refreshToken));
            user.spotifyCredentials.accessToken = encrypt(refreshedToken.accessToken);
            user.spotifyCredentials.expiresOn = Date.now() + (refreshedToken.expiresIn * 1000)
            await user.save()

            return refreshedToken.accessToken;
        } else {
            return decrypt(accessToken);
        }
    } catch (error) {
        user.spotifyConsent = false;
        console.error('Failed to fetch Spotify access token:', error);
        throw new Error('Failed to fetch access token');
    }
}

async function getCurrentPlayback(accessToken) {
    try {
        const response = await axios.get('https://api.spotify.com/v1/me/player', {
            headers: {
                'Authorization': `Bearer ${accessToken}`
            }
        });

        if (response.data && response.data.is_playing) {
            const currentTrack = response.data.item;
            const progressMs = response.data.progress_ms;
            const durationMs = currentTrack.duration_ms;
            const timeRemainingMs = (durationMs - progressMs);

            console.log(`Time remaining on the current track: ${timeRemainingMs} s`);
            return timeRemainingMs;
        } else {
            console.log('No track is currently playing.');
            return null;
        }
    } catch (error) {
        console.error('Error fetching current playback:', error.message);
        throw error;
    }
}

app.listen(PORT, (error) => {
    if (!error) {
        console.log("Server Running on Port " + PORT)
    } else {
        console.log("Error : " + error)
    }
})