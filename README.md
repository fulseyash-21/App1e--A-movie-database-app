App1e - A Modern Movie & TV Show Discovery App for iOS
laApp1e is a sleek and responsive iOS application built with Swift and UIKit for browsing, searching, and discovering movies and TV shows. It leverages The Movie Database (TMDB) API to provide up-to-date information on trending, popular, and upcoming titles. The entire UI is built programmatically, showcasing a strong understanding of Auto Layout and adaptive layouts for both portrait andndscape orientations.

✨ Features
Dynamic Home Feed: Browse through curated sections like Trending Movies, Popular TV Shows, Upcoming Releases, and Top Rated content.

Instant Search: Find any movie with a real-time search that uses debouncing to optimize network requests.

Detailed Previews: Get more information about a movie or TV show, including an overview and an embedded YouTube trailer.

Personal Watchlist: Save your favorite movies to a "My List" for easy access, with data persisted locally using UserDefaults.

Customizable Profile: Personalize your experience by choosing from a collection of avatars in a clean, modern profile screen.

Adaptive UI: A fully programmatic and responsive user interface that looks great on all devices in both portrait and landscape modes.

User Notifications: Receive local notifications when an item is added to your list.

Reusable Settings Component: A generic and reusable bottom sheet component for handling all user settings, demonstrating clean and scalable code architecture.

🛠️ Technologies & Architecture
UI: 100% Programmatic UI with UIKit and Auto Layout (No Storyboards).

Architecture: Model-View-ViewModel (MVVM) to ensure a clean separation of concerns.

Networking: Native URLSession for all API requests to TMDB and the YouTube Data API.

Concurrency: Asynchronous data fetching with completion handlers.

Image Caching: SDWebImage for efficient and asynchronous image loading and caching.

Persistence: UserDefaults for storing the user's watchlist and profile preferences.

Frameworks: WebKit for embedding YouTube trailers, UserNotifications for local alerts.

🚀 Setup and Installation
To run this project on your own device or simulator:

Clone the repository:

git clone [Your-Repository-URL]


Create Secrets.swift file:
Inside the App1e/ directory, create a new file named Secrets.swift.

Add Your API Keys:
Paste the following code into Secrets.swift and add your unique API keys from TMDB and the Google Cloud Console.

import Foundation

struct Secrets {
    static let tmdbApiKey = "YOUR_TMDB_API_KEY"
    static let youtubeDataApiKey = "YOUR_YOUTUBE_DATA_API_KEY"
}


Note: The Secrets.swift file is included in the .gitignore to prevent API keys from being exposed.

Open in Xcode and Run:
Open the .xcodeproj file and run the project on your desired simulator or physical device.

📂 Project Structure
The project is organized into logical groups to maintain a clean and scalable codebase:

Controllers: Contains all the UIViewController subclasses, separated into Core (for the main tab bar) and General (for reusable or secondary screens).

Views: Includes all custom UIView and UITableViewCell/UICollectionViewCell subclasses.

Models: Holds the data structures that model the API responses (e.g., Movie, TVShow).

ViewModels: Contains the ViewModels used to format model data for display in the views.

Services: Includes the NetworkManager responsible for all API interactions.

Presenters: Manages the presentation logic for complex views like the movie preview drawer.

Extensions: Contains helpful extensions on Swift and UIKit classes.

This project was developed by 
Yash Fulse
