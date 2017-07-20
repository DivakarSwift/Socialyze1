const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

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
    checkIn(request, response, (request, response, promise) => {
        promise.
            then(snapshot => {
                console.log("checked in");
                const url = constructUseDealUrl(request);
                const data = request.body.time;
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
    });
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
            body: notificationBody
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


