var admin = require('firebase-admin');
// 1. Download a service account key (JSON file) from your Firebase console and add to the example/scripts directory
var serviceAccount = require('./google-services.json');
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

// 2. Copy the token for your device that is printed in the console on app start (`flutter run`) for the FirebaseMessaging example
const token = 'dihRhOt4kUswhFrcwIRzPb:APA91bFZwiS0ZXx9Y0kUZF4-StluVk6IXziMNwhUbsbA1_MHFPgNI5l27XE3lYEqNjM5aq4CKp3Wt1B3oKLAJ5-fqNk1P3tJz3sf9C9jnwlN42Wtyw18V40icV0gyCjOuebwJqJ3egYX';


// 3. From your terminal, root to example/scripts directory & run `npm install`.
// 4. Run `npm run send-message` in the example/scripts directory and your app will receive messages in any state; foreground, background, terminated.
// If you find your messages have stopped arriving, it is extremely likely they are being throttled by the platform. iOS in particular
// are aggressive with their throttling policy.


admin.messaging().send(
    {
        token: token,
        data: {
            title: 'Hello',
            body: 'This is second notification',
            extraInt: '1',
            extraDouble: '1.0',
            event: 'type2',
        },
        android: {
            // Required for background/terminated app state messages on Android
            priority: 'high',
        },
        apns: {
            payload: {
                aps: {
                    // Required for background/terminated app state messages on iOS
                    contentAvailable: true,
                },
            },
        },
    },
)
    .then((res) => {
        if (res.failureCount) {
            console.log('Failed', res.results[0].error);
        } else {
            console.log('Success');
        }
    })
    .catch((err) => {
        console.log('Error:', err);
    });
