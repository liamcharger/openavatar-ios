# Welcome to Openavatar frontend for iOS

Openavatar is an open-source alternative to Gravatar, and products like it. This project was built for High Seas.

> [!IMPORTANT]  
> This project is in *very* early stages.

Since this project uses currently Firebase, you'll need to add a GoogleService-Info.plist to the project directory before running the app. You can get this file by creating a new Firebase project at [the Firebase Console](https://console.firebase.google.com) and adding an iOS app to it.

## In progress/todo:
- Add profile image and banner image uploads—Firebase Storage will be used to achieve this.
- Add NFC capabilites—this would allow a user to tap their phone to another user's NFC-enabled device to view their profile
- Web backend
  - Frontend would allow users to share their profile with devices that do not have the app installed, and would improve deeplink functionality
  - API for 3rd parties to fetch user data
