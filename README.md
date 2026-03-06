# Bloomer

An iOS app for smart plant care that communicates with an Arduino-based sensor system over Bluetooth Low Energy (BLE). Monitor your plant's environment in real time and control grow lights and a water pump directly from your phone.

## Features

- **Real-Time Sensor Monitoring** — View temperature, humidity, soil moisture, and light level readings from an Arduino sensor array
- **BLE Communication** — Seamless Bluetooth Low Energy connection between iOS and Arduino
- **Grow Light Control** — Toggle a NeoPixel LED strip on/off remotely
- **Automated Watering** — Configure and trigger a water pump with adjustable duration
- **Push Notifications** — Receive alerts when sensor readings need attention (e.g., low light)
- **User Authentication** — Firebase-powered login and sign-up
- **Dark Mode** — Toggle between light and dark themes
- **Profile Customization** — Set a custom profile image
- **Sound Effects** — Optional UI interaction sounds

## Tech Stack

| Component | Technology |
|-----------|------------|
| iOS App | Swift, UIKit, Storyboards |
| Authentication | Firebase Auth |
| Bluetooth | CoreBluetooth (BLE) |
| Microcontroller | Arduino (ArduinoBLE, DHT11, Adafruit NeoPixel) |
| Sensors | DHT11 (temp/humidity), soil moisture sensor, light sensor |
| Actuators | NeoPixel LED strip, water pump |

## Project Structure

```
├── Ok Bloomer Beta/          # iOS application source
│   ├── AppDelegate.swift     # App entry point, Firebase config
│   ├── LoginViewController.swift   # Firebase auth (login/signup)
│   ├── ViewController.swift        # Main dashboard with BLE + sensors
│   ├── PumpViewController.swift    # Water pump duration control
│   ├── PowerViewController.swift   # BLE connection status
│   ├── SettingsViewController.swift # Dark mode, sound toggles
│   ├── ProfileViewController.swift  # Profile image management
│   ├── AppSettings.swift           # Shared app preferences
│   ├── MyTabBarController.swift    # Tab navigation
│   ├── MyCollectionViewCell.swift  # Sensor data cell
│   └── Base.lproj/                 # Storyboards
├── Arduino Code/
│   └── sketch_nov13a/
│       └── sketch_nov13a.ino       # Arduino BLE + sensor firmware
└── Ok Bloomer Beta.xcodeproj/      # Xcode project
```

## Requirements

### iOS
- Xcode 15+
- iOS 15+
- Swift 5
- Firebase iOS SDK (via Swift Package Manager)

### Arduino
- Arduino board with BLE support (e.g., Arduino Nano 33 BLE)
- Libraries: `ArduinoBLE`, `Adafruit_NeoPixel`, `DHT`
- Hardware: DHT11 sensor, soil moisture sensor, light sensor, NeoPixel strip, water pump + relay

## Getting Started

### iOS App
1. Clone this repository
2. Open `Ok Bloomer Beta.xcodeproj` in Xcode
3. Add your own `GoogleService-Info.plist` from the [Firebase Console](https://console.firebase.google.com/)
4. Build and run on a physical device (BLE requires a real device)

### Arduino
1. Open `Arduino Code/sketch_nov13a/sketch_nov13a.ino` in the Arduino IDE
2. Install required libraries via the Library Manager
3. Upload to your Arduino board
4. Wire sensors and actuators according to the pin definitions in the sketch

## Hardware Wiring

| Component | Arduino Pin |
|-----------|-------------|
| DHT11 Data | D2 |
| NeoPixel DIN | D6 |
| Water Pump (relay) | D9 |
| Soil Moisture | A0 |
| Light Sensor | D4 |

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
