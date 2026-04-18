═══════════════════════════════════════════════════════════════
   श्री कृष्ण गीता संवाद — Flutter App Build Guide
═══════════════════════════════════════════════════════════════

📁 PROJECT STRUCTURE:
  gita_flutter/
  ├── lib/
  │   ├── main.dart                    ← App entry point
  │   ├── constants.dart               ← API keys यहाँ डालें ⚠️
  │   ├── models/message.dart          ← Message model
  │   ├── services/
  │   │   ├── api_service.dart         ← Claude + ElevenLabs API
  │   │   ├── audio_service.dart       ← Audio playback
  │   │   └── om_bell_service.dart     ← Om bell sound
  │   ├── widgets/
  │   │   ├── welcome_screen.dart      ← Welcome UI
  │   │   └── message_bubble.dart     ← Chat bubble UI
  │   └── screens/home_screen.dart    ← Main screen
  ├── android/                         ← Android config
  └── pubspec.yaml                     ← Dependencies

═══════════════════════════════════════════════════════════════
STEP 1 — Flutter Install करें (अगर नहीं है):
  https://flutter.dev/docs/get-started/install
  
  Windows: winget install Flutter.Flutter
  
  Verify: flutter doctor

═══════════════════════════════════════════════════════════════
STEP 2 — API Keys डालें:
  lib/constants.dart खोलें:
  
  static const String anthropicKey = 'sk-ant-api...आपकी key...';
  static const String elevenLabsKey = 'sk_d1ff...आपकी key...';

═══════════════════════════════════════════════════════════════
STEP 3 — Dependencies install करें:
  Terminal में project folder में जाएँ:
  
  cd gita_flutter
  flutter pub get

═══════════════════════════════════════════════════════════════
STEP 4 — APK Build करें:
  
  # Debug APK (testing के लिए):
  flutter build apk --debug
  
  # Release APK (Play Store के लिए):
  flutter build apk --release
  
  APK मिलेगी:
  build/app/outputs/flutter-apk/app-release.apk

═══════════════════════════════════════════════════════════════
STEP 5 — Play Store के लिए Sign करें:
  
  # Keystore बनाएँ (एक बार):
  keytool -genkey -v -keystore gita-key.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias gita-krishna
  
  # android/key.properties बनाएँ:
  storePassword=आपका password
  keyPassword=आपका password
  keyAlias=gita-krishna
  storeFile=../../gita-key.jks
  
  # Release build:
  flutter build appbundle --release
  
  # AAB मिलेगी:
  build/app/outputs/bundle/release/app-release.aab

═══════════════════════════════════════════════════════════════
STEP 6 — Play Store पर Upload:
  1. play.google.com/console पर जाएँ
  2. $25 Developer account fee
  3. New App → Upload .aab file
  4. Screenshots + Description add करें
  5. Submit for review (3-7 दिन)

═══════════════════════════════════════════════════════════════
⚠️ IMPORTANT NOTES:
  - API keys को constants.dart में ही रखें
  - Release build से पहले keys ज़रूर डालें
  - flutter doctor से सब check करें
  - Android Studio या VS Code recommend है

═══════════════════════════════════════════════════════════════
🆘 अगर error आए:
  flutter clean
  flutter pub get
  flutter build apk --release
═══════════════════════════════════════════════════════════════
