import UIKit

class UpcomingViewController: UIViewController {
    
    private var moviePreviewPresenter: MoviePreviewPresenter!
    private var movies: [Movie] = []

    private let upcomingTable: UITableView = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Coming Soon"
        view.backgroundColor = .systemBackground

        view.addSubview(upcomingTable)
        view.addSubview(activityIndicator)
        
        moviePreviewPresenter = MoviePreviewPresenter(parentViewController: self)
        
        setupConstraints()
        setupEmptyStateView()

        upcomingTable.delegate = self
        upcomingTable.dataSource = self

        fetchUpcoming()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            upcomingTable.topAnchor.constraint(equalTo: view.topAnchor),
            upcomingTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upcomingTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upcomingTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupEmptyStateView() {
        let emptyLabel = UILabel(frame: upcomingTable.bounds)
        emptyLabel.text = "No upcoming movies."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        upcomingTable.backgroundView = emptyLabel
        upcomingTable.backgroundView?.isHidden = true
    }

    private func fetchUpcoming() {
        activityIndicator.startAnimating()
        upcomingTable.backgroundView?.isHidden = true
        NetworkManager.shared.fetchUpcomingMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    self?.upcomingTable.reloadData()
                    self?.upcomingTable.backgroundView?.isHidden = !movies.isEmpty
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.upcomingTable.backgroundView?.isHidden = false
                }
            }
        }
    }
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: MovieViewModel(title: movies[indexPath.row].title, posterPath: movies[indexPath.row].posterPath ?? ""))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        let viewModel = MoviePreviewViewModel(
            title: movie.title,
            overview: movie.overview,
            imagePath: movie.backdropPath
        )
        moviePreviewPresenter.presentDrawer(with: viewModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

