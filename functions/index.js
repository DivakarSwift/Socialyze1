const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// The Firebase Admin SDK to access the Firebase Realtime Database.
// const admin = require('firebase-admin');
// admin.initializeApp(functions.config().firebase);
//
const admin = require('firebase-admin');
admin.initializeApp(
    functions.config().firebase
);

// exports.helloWorld = functions.https.onRequest((request, response) => {
//     response.send("Hello from Firebase!");
// });

exports.iAmGoing = functions.https.onRequest((request, response) => {
    const placeId = request.body.placeId;
    const userId = request.body.userId;
    const fbId = request.body.fbId;
    const time = request.body.time;
    const friendsFbId = request.body.friendsFbId;
    const notificationTitle = request.body.notificationTitle;
    const notificationBody = request.body.notificationBody;

    const url = "/Places/" + placeId + "/going/" + userId;

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
                // console.log("here");
                // console.log(element);
                admin.database().ref("user").orderByChild("profile/fbId").equalTo(element).once('value')
                    .then(snapshot => {
                        // console.log("here2");
                        let token;
                        snapshot.forEach(function (data) {
                            token = data.val().fcmToken;
                        });
                        // console.log(token);
                        admin.messaging().sendToDevice(token, payload)
                            .then(function (response) {
                                console.log("push notification message sent");
                            })
                            .catch(function (error) {
                                console.log("error in sending message");
                            });
                    }).catch(function (error) {
                        // console.log("error MAN");
                        console.log(error);
                    });
            }, this);

            // console.log("ddd");
        });
});


