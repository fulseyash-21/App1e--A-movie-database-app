import Foundation

struct MovieViewModel {
    let title: String
    let posterURL: URL?

    init(title: String, posterPath: String?) {
        self.title = title
        if let posterPath = posterPath {
            self.posterURL = URL(string: "\(Constants.imageBaseURL)\(posterPath)")
        } else {
            self.posterURL = nil
        }
    }
}
