import Foundation

struct MoviePreviewViewModel {
    let title: String
    let overview: String
    let imageURL: URL?
    let imagePath: String?

    init(title: String, overview: String, imagePath: String?) {
        self.title = title
        self.overview = overview
        self.imagePath = imagePath
        if let path = imagePath {
            self.imageURL = URL(string: "\(Constants.imageBaseURL)\(path)")
        } else {
            self.imageURL = nil
        }
    }
}
