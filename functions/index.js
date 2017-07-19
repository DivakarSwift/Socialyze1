const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.iAmGoing = functions.https.onRequest((request, response) => {
    const placeId = request.body.placeId;
    const userId = request.body.userId;
    const fbId = request.body.fbId;
    const time = request.body.time;
    const friendsFbId = request.body.friendsFbId;
    const notificationTitle = request.body.notificationTitle;
    const notificationBody = request.body.notificationBody;
    const eventUid = request.body.eventUid

    const url = "/Places/" + placeId + "/going/" + eventUid + "/" + userId;
    
    admin.database().ref(url).set({
        "time": time,
        "fbId": fbId,
        "userId": userId
    }).then(snapshot => {
        response.status(200).send(request.body.userId);
    })
        .then(() => {
            const payload = {
                notification: {
                    title: notificationTitle,
                    body: notificationBody
                }
            };

            friendsFbId.forEach(function (element) {

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

            // console.log("ddd");
        });
});

function sendPushNotification(registrationToken, payload) {
    admin.messaging().sendToDevice(registrationToken, payload)
        .then(function (response) {
            console.log("push notification message sent");
        })
        .catch(function (error) {
            console.log("error in sending message");
        });
}


