import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct TVResponse: Codable {
    let results: [TVShow]
}
