var admin = require('firebase-admin');
var serviceAccount = require('./google-services.json');
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const token = 'e4JrDaJEkUQ7uyInUuiDrt:APA91bHPXADFC5-DJULWpUcXivnN7BNyJJ1OgZRoLIRbDXGoZGQEuqll5l6OTY6q76McPHlh9xglzNyMh7zuqu7769oSPzle7A1C0RBpSK2_chpEFtzHixejL5PkJQDHaAfWjgzJR15c';

const eventType = process.argv[2];

admin.messaging().send(
    {
        token: token,
        notification: {
            title: 'Hello',
            body: 'This is notification of ' + eventType,
        },
        data: {
            extraInt: '1',
            extraDouble: '1.0',
            event: eventType,
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
