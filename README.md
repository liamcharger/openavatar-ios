# Welcome to OpenID

OpenID is an open-source alternative to Gravatar, and products like it. This project was built for High Seas.

Since this project uses Firebase, you'll need to add a GoogleService-Info.plist to the project directory before running the app. You can get this file by creating a new Firebase project at [the Firebase Console](https://console.firebase.google.com) and adding an iOS app to it.

## TODO:
- [ ] Implement the ability to login—right now, users can only register, and can't return to their account if the app is uninstalled.
- [ ] Add profile image and banner image uploads—Firebase Storage will be used to achieve this.
- [ ] Add NFC capabilites—this would allow a user to tap their phone to another user's NFC-enabled device to view their profile
- [ ] Web backend—this would allow users to share their profile with devices that do not have the app installed, and would improve deeplink functionality
