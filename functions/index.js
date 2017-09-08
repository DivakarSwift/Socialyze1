const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
// const serviceAccount = require("../socialyze-72c6a-firebase-adminsdk-pz0iq-19c1c1ae1c.json");

admin.initializeApp({
    credential: admin.credential.cert({
        "type": "service_account",
        "project_id": "socialyze-72c6a",
        "private_key_id": "19c1c1ae1c0820292bbecefa023f463bbb3ecc24",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCwKRD+IkuyCH93\n2hUyJum7XsvUe5AS78UcXGRl4o3s1ZYItjGKCCPnlxNsnhg6EtA6suknSngtYnhW\nM0p9yxjS+bTpVv+vk79BvW7WvWaEjZHwGTIMkgMvkVg2Osu5vn4WmW0D3H5SAkYP\nNoVCC40PmEOi+ictOyfLJmpjqTWrJnsvmmmWyXOgcab+t4ll2EduidS1QSTGpsTW\n5GN6SGlHLB6NY6GtSmLAj6CsR+/xnI4wjbaggh/T7SF2qWoefhBOVAXS5RwzkLQn\nKcSJRNHAB9JkLOdPDe8NH89GmPuCUBuo69z6Cd68bBXflxMoeH51hj1J/HwSG8Ob\nUNxVZnvJAgMBAAECggEADumrEph8p/moMNE5ciFxL/d6ceZz7+Z0XU5FAYsIUMBU\nDzC9SN4fi/9yGYPYsTHehtmWe0kGm3D2lvWInNWQqGuTMR24T3jGfB45P9yQzS/e\n5uB7KC1EL8ayHQUlMfg6XFdoryb/WpnurGMFLO4lZuiQ8T8UCfQ0DjKWVxGABZj8\nYDINaZKdB9VOAQx2Fh2o81Sn/t+YQwkUA2QRRVF3fBSCfFq3/GV1OJlcAXLFYWaa\nwcCKj1OLWKUeQQKX7ZF7tOvc3Mgp+e14r76Ab0bdclbXY3JiawS/yv3KXmLTq0tV\n1Xv0QYgm/1mivCNHwm8frZ8+5oNkOv52ElGhIqBaAQKBgQDdY7y6S7L/bcMujmuT\nvTJOGsrV03VVYLRMKzD2DiA4KjKusKvFg5hSfhSJM7GJHF/lojSYU5eCNKWjeLak\nEwSbrOYjv4K1jZNgfwkBZ7OPAKtQq+OW/g3fQGehTmSAMdluLnYcX7DHJe9evbQA\nlUUMS0LFDnUP24kbZImJGlNEEQKBgQDLszS6YobsDmXZaheU0xyC+K2tUsXCW11h\nwyM/Nz5NpnrjLd+2LpzDYhuj/A77CRoi6QE/h4NRM3fmi6jm5Bh/OYkeCBQD/a+v\ns5vc45V49LBoJLt6JjfbZLufqDsIC0ue3AP575naJg3gZPpVT4PSSsw2ca/m18OE\n7MeI7dsUOQKBgCQa3+yB6+88N1igYWr2r/2M4Qd+NOR3oO/LG3EFXLvMJffXWCwe\nCflqFm9JvupddkY87dbpywuxClJenWqkr1u0FtQ9p1N0g1R5Yz6XavEnasj9P2Cg\njiKankvwPPOrLYqKiTiXYn0X8rHAvlpZ/ajDnWAFu5GafAG7o7J4WJwBAoGAZ0v/\nRy1Dol1CxNgKEUxlPv2AhU5ePss6NaNRMnN/Qr1Tv/S5Z5eHo4US4zulFSRufpmO\nKns72mexO9ZC1qOA0LOKlxIdpFB3UTBRr9gxKl9bPdSyxaSv2q/gfXxAQzoHJQ4J\nbitU5804aDyMvcpO3MtVd557RyLPYY75OLT1zfECgYBHv7J6GPKj7hxrbBDjp/0J\n+EwJk8hJH+8BqsFzBG2gCEHAjoFtg9sNYJ9bOCfPNvCMnKJxO9zVFQBfDD5y4an9\nrA1ae2cEc7D93KATB92tzpsJ9b1Km03yfRWxT8t8G3vMm+DxBst1RZNN3QukXTiW\nXAyUKiaw8xHxFWRhwEZ/Mw==\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-pz0iq@socialyze-72c6a.iam.gserviceaccount.com",
        "client_id": "116251393354409597491",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://accounts.google.com/o/oauth2/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-pz0iq%40socialyze-72c6a.iam.gserviceaccount.com"
    }),
    databaseURL: "https://socialyze-72c6a.firebaseio.com",
    storageBucket: "socialyze-72c6a.appspot.com"
});

// var bucket = admin.storage().bucket();

exports.helloWorld = functions.https.onRequest((request, response) => {
    response.send("Hello from Firebase!");
});

exports.iAmGoing = functions.https.onRequest((request, response) => {
    const url = constructIAmGoingUrl(request);
    const data = constructIAmGoingData(request);

    const promise = admin.database().ref(url).set(data)
    handlePromise(request, response, promise);
});

exports.checkIn = functions.https.onRequest((request, response) => {
    checkIn(request, response, handlePromise);
});

exports.useDeal = functions.https.onRequest((request, response) => {
    // checkIn(request, response, (request, response, promise) => {
    //     promise.
    //         then(snapshot => {
    // console.log("checked in");
    const data = request.body.time;
    const userUseDealUrl = constructUserUseDealUrl(request);
    admin.database().ref(userUseDealUrl).set(data)
        .then(snapshot => {
            const url = constructUseDealUrl(request);
            admin.database().ref(url).set(data)
                .then(snapshot => {
                    const useDealCountUrl = constructUseDealCountUrl(request);
                    const ref = admin.database().ref(useDealCountUrl)
                    ref.once("value")
                        .then(snapshot => {
                            const count = snapshot.val();
                            const newCount = count + 1;
                            const promise = ref.set(newCount);
                            handlePromise(request, response, promise);
                        });
                });
        });
    // });
    // });
});

function handlePromise(request, response, promise) {
    promise
        .then(snapshot => {
            response.status(200).send("saved");
        })
        .then(() => {
            sendPushNotificationToFacebookUsers(request);
        });
}

// I am going
function constructIAmGoingUrl(request) {
    const placeId = request.body.placeId;
    const userId = request.body.userId;
    const eventUid = request.body.eventUid;

    return ("/Places/" + placeId + "/going/" + eventUid + "/" + userId);
}

function constructIAmGoingData(request) {
    const userId = request.body.userId;
    const fbId = request.body.fbId;
    const time = request.body.time;

    let value = {
        "time": time,
        "fbId": fbId,
        "userId": userId
    };
    return value;
}

// checkin
function constructCheckInUrl(request) {
    const placeId = request.body.placeId;
    const userId = request.body.userId;

    return ("/Places/" + placeId + "/checkIn/" + userId);
}

function constructUserCheckInUrl(request) {
    const userId = request.body.userId;
    return ("/user/" + userId + "/checkIn");
}

function constructCheckInData(request) {
    const userId = request.body.userId;
    const fbId = request.body.fbId;
    const time = request.body.time;

    let value = {
        "time": time,
        "fbId": fbId,
        "userId": userId
    };
    return value;
}

function constructUserCheckInData(request) {
    const place = request.body.place;
    const time = request.body.time;

    let value = {
        "time": time,
        "place": place
    };
    return value;
}

function checkIn(request, response, callback) {
    const url = constructCheckInUrl(request);
    const data = constructCheckInData(request);

    admin.database().ref(url).set(data)
        .then(snapshot => {

            const userCheckInUrl = constructUserCheckInUrl(request);
            const userCheckInData = constructUserCheckInData(request);
            const promise = admin.database().ref(userCheckInUrl).set(userCheckInData);
            callback(request, response, promise);
        });
}

// Use deal

function constructUseDealUrl(request) {
    const placeId = request.body.placeId;
    const dealUid = request.body.dealUid;
    const userId = request.body.userId;

    return ("Places/" + placeId + "/deal/" + dealUid + "/users/" + userId + "/time");
}

function constructUserUseDealUrl(request) {
    const placeId = request.body.placeId;
    const userId = request.body.userId;

    return ("Places/" + placeId + "/userDeal/" + userId);
}
// .child("Places").child(placeName).child("deal").child(place.deal?.uid ?? "--1").child("users")
// FirebaseManager().reference.child("Places").child(placeName)
//.child("deal").child(place.deal?.uid ?? "--1").child("useCount")
function constructUseDealCountUrl(request) {
    const placeId = request.body.placeId;
    const dealUid = request.body.dealUid;

    return ("Places/" + placeId + "/deal/" + dealUid + "/useCount");
}
// Other functions
function getNotificationPayload(request) {
    const notificationTitle = request.body.notificationTitle;
    const notificationBody = request.body.notificationBody;

    return {
        notification: {
            title: notificationTitle,
            body: notificationBody,
            sound: "default"
        }
    };
}

function sendPushNotificationToFacebookUsers(request) {
    const facebookfriendsId = request.body.friendsFbId;
    const payload = getNotificationPayload(request);

    facebookfriendsId.forEach(function (element) {
        admin.database().ref("user").orderByChild("profile/fbId").equalTo(element).once('value')
            .then(snapshot => {
                let token;
                snapshot.forEach(function (data) {
                    token = data.val().fcmToken;
                });
                if (typeof token === 'string' || token instanceof String) {
                    console.log(token);
                    sendPushNotification(token, payload);
                }
            }).catch(function (error) {
                console.log(error);
            });
    }, this);
}

function sendPushNotification(registrationToken, payload) {
    admin.messaging().sendToDevice(registrationToken, payload)
        .then(function (response) {
            console.log("push notification message sent");
        })
        .catch(function (error) {
            console.log("error in sending message");
        });
}

var gcloud = require('google-cloud');
var gcs = gcloud.storage({
    projectId: 'socialyze-72c6a',
    keyFilename: 'socialyze-72c6a-firebase-adminsdk-pz0iq-19c1c1ae1c.json'
});

// const gcs = require('@google-cloud/storage')();
var request = require('request');
const bucket = gcs.bucket('socialyze-72c6a.appspot.com');

// On profile images set
exports.newImageUploadedFromFB = functions.database.ref('/user/{userId}/profile')
    .onCreate(event => {
        const images = event.data.val().images;
        console.log('images:');
        console.log(images);
        var newImages = [];
        return new Promise(function (fulfil, reject) {
            var acknowledgedCount = 0;
            for (var image of images) {
                console.log(image);
                const nameOfFile = filename(image);
                console.log(nameOfFile);
                var file = bucket.file(nameOfFile);
                
                var config = {
                    action: 'read',
                    expires: '03-17-2025'
                };

                file.getSignedUrl(config, function (err, url) {
                    if (err) {
                        console.error(err);
                        return;
                    }
                    newImages.push(url);
                });
                request(image).pipe(file.createWriteStream())
                    .on('error', function (err) {
                        console.log(err);
                        console.log("error download file");
                        acknowledgedCount++;
                        if (acknowledgedCount == images.length) {
                            event.data.ref.child('images').set(newImages)
                            .then(value => {
                                fulfil();
                            });
                        }
                    })
                    .on('finish', function () {
                        console.log("success download file");
                        acknowledgedCount++;

                        if (acknowledgedCount == images.length) {
                            event.data.ref.child('images').set(newImages)
                            .then(value => {
                                fulfil();
                            });
                        }
                    });
            }
        });
    });

function filename(path) {
    path = path.substring(path.lastIndexOf("/") + 1);
    return (path.match(/[^.]+(\.[^?#]+)?/) || [])[0];
}