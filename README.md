# 📍 Pathfinder - Discover Products Near You

**Pathfinder** is a powerful iOS application designed to bridge the gap between digital searching and physical shopping. It allows users to search for products, check real-time stock availability in nearby stores, and get instant directions—all within a seamless, interactive map experience.

---

## ✨ Key Features

### 🔍 Smart Product Search & Discovery
Easily search through a vast database of products. Once a product is selected, Pathfinder scans nearby stores to find exactly where it is in stock.

### 🗺️ Interactive Map Experience
- **Real-time Store Markers:** Visualize store locations on an interactive map.
- **User Location:** Real-time tracking of your current position using CoreLocation.
- **Dynamic Radius Filter:** Use the custom animated slider to adjust your search radius (e.g., 500m to 10km).

> > ![Map & Slider Demo](https://raw.githubusercontent.com/username/repo/main/screenshots/map_demo.gif)
> *Interactive map with custom distance slider and loader animation.*

### 🛠️ Advanced Filtering & Sorting
Find exactly what you need by sorting results based on:
- **Distance:** Closest stores first.
- **Price:** Most affordable options.
- **Stock Availability:** Stores with the highest stock levels.

### 🛣️ Routing & Directions
Found the perfect deal? Get there faster with integrated Apple Maps routing. Launch directions directly from the store's detail view.

### 👤 Personalized Experience (Account Section)
- **Favorites:** Save products you love for quick access. Synced in real-time.
- **View History:** Never lose track of what you've looked at. Your recent views are automatically saved.

---

## 💻 Technical Architecture

The project is built with a focus on modularity and real-time performance using the **MVVM** pattern and **Service-Oriented Architecture**.

### Tech Stack
* **UI Framework:** 100% **SwiftUI** for a modern, declarative interface.
* **Backend & Auth:** **Firebase** (Firestore for real-time data & Firebase Auth for Secure Login).
* **Social Login:** Integrated **Google Sign-In** and **Apple Sign-In**.
* **Maps:** **MapKit** & **CoreLocation** for spatial calculations and navigation.

### Core Components
- **MapService:** Handles coordinate logic and store fetching within specified radiuses.
- **FavoriteService & HistoryService:** Manages user-specific data synchronization with Firestore.
- **Custom UI Components:** - `DistanceSliderView`: A custom-built slider with a `CircularLoader` animation using `DispatchWorkItem` for efficient API call debouncing.
    - `ProductFilter`: A sophisticated list view with expandable items and dynamic sorting.

---

## 📸 Demos

| Search & Discovery |

| ![Search GIF](https://github.com/mealuc/iOS-PathFinder/blob/8a9921f459faaf30593a5d4706926bce4e6c3780/Assets/searchnewgif.gif) 

| Map Interaction |

| ![Map GIF](https://github.com/mealuc/iOS-PathFinder/blob/8a9921f459faaf30593a5d4706926bce4e6c3780/Assets/mapinteractionnewgif.gif) 

| Profile & Favorites |

| ![Profile GIF](https://github.com/mealuc/iOS-PathFinder/blob/8a9921f459faaf30593a5d4706926bce4e6c3780/Assets/accountnewgif.gif) 

| Filter Product |

| ![Filter GIF](https://github.com/mealuc/iOS-PathFinder/blob/8a9921f459faaf30593a5d4706926bce4e6c3780/Assets/filternewgif.gif)

---

## 🚀 Installation & Setup

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/yourusername/Pathfinder.git](https://github.com/yourusername/Pathfinder.git)
    ```
2.  **Firebase Setup:**
    - Create a project on [Firebase Console](https://console.firebase.google.com/).
    - Add an iOS app and download the `GoogleService-Info.plist`.
    - Place the plist file in the root of your Xcode project.
3.  **Run the Project:**
    - Open `Pathfinder.xcodeproj`.
    - Select your target device/simulator and press `Cmd + R`.

---
