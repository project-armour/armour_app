

# Armour – Personal Safety App

*A Flutter-powered safety companion with real-time location sharing and a connected wearable band.*

---

## 📱 Overview

**Armour** is a cross-platform personal safety application built with **Flutter**, designed to work seamlessly with the custom **Armour Band** wearable.
The app enhances user safety through real-time location sharing, alert triggers, motion-based monitoring, and Bluetooth-enabled panic actions.

---

## ✨ Key Features

### 🔐 Authentication

* Secure login and account creation
* Profile setup with name, username, and optional avatar

### 🗺️ Live Location Map

* See all your added contacts on a dynamic real-time map
* View their most recent location and safety status
* Share your live location with contacts

### 📡 Bluetooth Wearable Integration

* Connect your **Armour Band** via Bluetooth LE
* Automatic reconnection & background service support
* Triggers for fake calls, panic mode, and emergency alerts

### 👥 Contact Management

* Add trusted contacts to share & receive alerts
* Real-time updates for location, panic alerts, and emergency triggers

### 🚶 Pace Tracking

* User-configurable normal walking speed
* Alerts generated when speed threshold is exceeded

### 🚨 Emergency Actions

Triggered from either the **Armour Band** or the app:

* Panic mode
* Fake/decoy call
* Continuous location sharing during emergencies

---

## 📸 Screenshots
(TODO)

---

## 🔑 Environment Variables

This project requires a **Stadia Maps API key** for map rendering.

1. Sign up at **[https://stadiamaps.com/](https://stadiamaps.com/)**
2. Create an API key from the developer dashboard
3. In the root of the project, create a `.env` file:

```
STADIA_MAPS_KEY=your_api_key_here
```

---

## 🛠️ Tech Stack

### **Frontend**

* [Flutter (Dart)](https://flutter.dev/)
* [Flutter Map Library](https://docs.fleaflet.dev/)
* [Stadia Maps (Map Tiles)](https://stadiamaps.com/)
* [Bluetooth Low Energy with Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus)

### **Backend**

* Supabase with Supabase Realtime

### **Wearable**

* Custom “Armour Band” with:

  * BLE communication
  * SOS panic button
  * Sensors for pacing, heart rate, etc.
  * Vibration motor and buzzer to alert the user/nearby people.
  * Built on ESP32 microcontroller

* Firmware developed with MicroPython, source code: [esp-armour-v2](https://github.com/project-armour/esp-armour-v2)

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (latest stable)
* Android Studio / Xcode
* A physical device (recommended for BLE)
* Armour Band (for testing)

### Setup

```bash
git clone https://github.com/yourusername/armour-app.git
cd armour-app
flutter pub get
```

Create `.env` → add your `STADIA_MAPS_KEY` → then run:

```bash
flutter run
```

---

