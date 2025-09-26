import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    enum APIError: Error {
        case invalidURL
        case noData
        case decodingError
    }
    
    // MARK: - Movie & TV Show Requests
    
    func fetchTrendingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/trending/movie/day?api_key=\(Secrets.tmdbApiKey)"
        performRequest(urlString: urlString, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTrendingTVShows(completion: @escaping (Result<[TVShow], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/trending/tv/day?api_key=\(Secrets.tmdbApiKey)"
        performRequest(urlString: urlString, responseType: TVResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchUpcomingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/movie/upcoming?api_key=\(Secrets.tmdbApiKey)&language=en-US&page=1"
        performRequest(urlString: urlString, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchPopular(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/movie/popular?api_key=\(Secrets.tmdbApiKey)&language=en-US&page=1"
        performRequest(urlString: urlString, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTopRated(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/movie/top_rated?api_key=\(Secrets.tmdbApiKey)&language=en-US&page=1"
        performRequest(urlString: urlString, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchDiscoverMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)/discover/movie?api_key=\(Secrets.tmdbApiKey)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate"
        performRequest(urlString: urlString, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func search(with query: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {return}
        let urlString = "\(Constants.baseURL)/search/movie?api_key=\(Secrets.tmdbApiKey)&query=\(query)"
        performRequest(urlString: urlString, responseType: MovieResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - YouTube Request
    
    func getYouTubeVideoId(with movieName: String, completion: @escaping (Result<[YouTubeSearch.Item], Error>) -> Void) {
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=1&q=\(movieName)%20trailer&key=\(Secrets.youtubeDataApiKey)"
        performRequest(urlString: urlString, responseType: YouTubeSearch.Response.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Helper
    
    private func performRequest<T: Codable>(urlString: String, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(APIError.decodingError))
            }
        }.resume()
    }
}

