import UIKit

class SearchViewController: UIViewController {

    private var movies: [Movie] = []
    private var moviePreviewPresenter: MoviePreviewPresenter!
    
    private let debouncer = Debouncer(delay: 0.5)

    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or a TV show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always

        view.addSubview(discoverTable)
        view.addSubview(activityIndicator)
        
        moviePreviewPresenter = MoviePreviewPresenter(parentViewController: self)
        
        setupConstraints()
        setupEmptyStateView()

        discoverTable.delegate = self
        discoverTable.dataSource = self

        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .label

        fetchDiscoverMovies()
        searchController.searchResultsUpdater = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            discoverTable.topAnchor.constraint(equalTo: view.topAnchor),
            discoverTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            discoverTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            discoverTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        let emptyLabel = UILabel(frame: discoverTable.bounds)
        emptyLabel.text = "No movies to discover."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        discoverTable.backgroundView = emptyLabel
        discoverTable.backgroundView?.isHidden = true
    }

    private func fetchDiscoverMovies() {
        activityIndicator.startAnimating()
        discoverTable.backgroundView?.isHidden = true
        NetworkManager.shared.fetchDiscoverMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.discoverTable.reloadData()
                    self?.discoverTable.backgroundView?.isHidden = !movies.isEmpty
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.discoverTable.backgroundView?.isHidden = false
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        let movie = movies[indexPath.row]
        cell.configure(with: MovieViewModel(title: movie.title, posterPath: movie.posterPath ?? ""))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        let viewModel = MoviePreviewViewModel(title: movie.title, overview: movie.overview, imagePath: movie.backdropPath)
        moviePreviewPresenter.presentDrawer(with: viewModel)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            (searchController.searchResultsController as? SearchResultsViewController)?.movies = []
            return
        }
        
        debouncer.debounce {
            NetworkManager.shared.search(with: query) { result in
                switch result {
                case .success(let movies):
                    resultsController.movies = movies
                case .failure(let error):
                    print(error.localizedDescription)
                    resultsController.movies = []
                }
            }
        }
    }
}

