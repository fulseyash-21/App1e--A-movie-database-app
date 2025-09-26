import Foundation

// Namespacing the YouTube search response models to avoid naming conflicts and improve organization.
enum YouTubeSearch {
    struct Response: Codable {
        let items: [Item]
    }

    struct Item: Codable {
        let id: VideoId
    }

    struct VideoId: Codable {
        let videoId: String?
    }
}
