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

exports.helloWorld = functions.https.onRequest((request, response) => {
    response.send("Hello from Firebase!");
});

exports.iAmGoing = functions.https.onRequest((request, response) => {
    const placeId = request.body.placeId;
    const userId = request.body.userId;
    const fbId = request.body.fbId;
    const time = request.body.time;
    const friends = request.body.friends; 
    console.log(friends); 
    
    const url = "/Places/" + placeId + "/going/" + userId;
    
    admin.database().ref(url).set({
        "time": time,
        "fbId": fbId,
        "userId": userId
    }).then(snapshot => {
        response.status(200).send(request.body.userId);
    }).then(() => {
        console.log("ddd");
    });
});


