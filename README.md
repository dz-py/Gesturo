<img src="assets/logo.png" alt="Gesturo Logo" width="60" height="60" />

# Gesturo: Wireless Touchpad Application

Gesturo is an iOS application that allows you to control your computer's cursor through gestures made on your IOS device. It enables you to perform touchpad actions such as left and right clicks, scrolling, and cursor movements.

## Motivation

The main motivation for building Gesturo was to create a simple and intuitive way to control a computer's cursor remotely using gesture input on a mobile device.

## Technologies Used

- **Python**: For backend development using a WebSocket server to handle gesture data.
- **SwiftUI**: For building the iOS app's interface, including gesture handling.
- **pynput**: For controlling the cursor and various gestures.

## Features

- **Gesture Control**: Tap, double tap, swipe, and two-finger gestures to perform actions like clicks and scrolling.
- **Real-Time Feedback**: Immediate cursor movements based on gesture data.
- **WebSocket Communication**: Ensures low-latency communication between the iOS app and the backend.

## How to Install and Run the Project

### Backend (Python)

1. Clone this repository.
2. Make a virtual environment and activate it:
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```
3. Install required Python dependencies:
    ```bash
    pip3 install -r requirements.txt
    ```
4. Start the server:
    ```bash
    python3 main.py
    ```

### Frontend (iOS)

1. Clone this repository and open the iOS project in Xcode.
2. Build and run the app on your iOS device (need a cable connecting your computer to your device).

## How to Use the Project

1. Open the iOS app on your device.
2. Connect to the WebSocket server (you'll need a config.json file to store your websocket url):
    ```bash
    config.json:
    {
    "WS_URL": "ws://IP_Address:5007"
    }
    ```
3. Use gestures on the touchpad interface to move the cursor, click, or scroll on your computer.


## License
This project is open source and available under the [MIT License](https://opensource.org/license/mit).

