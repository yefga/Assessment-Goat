# Goat Weather
### Overview
Welcome to the Goat Weather App! This iOS application serves as a demonstration for implementing a simple weather widget and serves as a coaching tool for junior iOS engineers. The app showcases various features, including displaying weather information using the OpenWeatherMap API, allowing users to set their own images from their gallery, and presenting the current weather in a widget.

### Minimum Specification
1. Widget Options:
- The app displays three widget options using a UICollectionView with custom cells.
Location and Weather:

2. Requests location permission from users.
- Connects to the OpenWeatherMap API to fetch the current weather.
- Implements error handling for users who deny location permission.

3. Automatic Location Assignment and Weather Display:
- Automatically assigns users' location based on their device information.
Displays weather conditions such as Sunny, Cloudy, Sun behind cloud, Raining, and Snow.
4. User Image Selection:
- Allows users to set their own image from their gallery.
Requires access to the Photo Library using NSPhotoLibraryUsageDescription.
5. Weather Widget:
- Shows the current weather in a widget using WidgetKit.

## Implementation Details
### Network Layer
The application follows a structured network layer with the following components:

1. NetworkService: Handles making requests and returning responses as data or failures in the form of NetworkError.
2. NetworkClient: Where users make requests and receive decodable responses if the result is successful.
3. Provider: Customizes network requests, including path endpoint, API key, and parameters.

### Weather Display
To display weather conditions, the app utilizes the OpenWeather API's icon inside the JSON response. The recommended URL for weather icons is http://openweathermap.org/img/wn/{icon}@2x.png.

### Photo Library & Location Access
For users to set their own images from the gallery, the app requests access to the Photo Library using **NSPhotoLibraryUsageDescription**. The UIImagePickerControllerDelegate is implemented to access the user's gallery. And for Location using **NSLocationAlwaysUsageDescription**

### Widget Implementation
The app includes a Widget Extension to implement WidgetKit. Shared data between the app and the widget is achieved through app group capabilities, enabling data sharing between extensions.

### Architecture
The app follows the MVVM architecture with Combine. This choice is made due to Combine's built-in publisher for any property compliant with Key-Value Observing. It allows the coordination of multiple publishers and their interaction, making it ideal for handling updates from various components.

```
- Application
     - Services
          - Network
               - NetworkService
               - NetworkClient
               - NetworkError
               - Request (Provider)
          - Database
               - FileManager (for saving selected images)
               - UserDefaults (for saving coordinates)
     - UI
     - Modules 
          - ViewModel
          - View
          - Model / Entities

```


This folder structure organizes the application into clear sections, making it easier for developers to navigate and understand the codebase.

## Getting Started
To start the project, simply open the file Goat-Weather.xcodeproj.

## Adding a New Feature
To create a new feature, start by creating a new folder with the name of your new feature inside the Goat-Weather folder. This helps maintain a clean and organized project structure.

Feel free to explore and build upon this Weather Widget App as you continue your journey in iOS development!


## Preview

<details>
     
<summary>iPhone SE 3, iOS 17</summary>

![iOS](./preview.gif)

</details>
