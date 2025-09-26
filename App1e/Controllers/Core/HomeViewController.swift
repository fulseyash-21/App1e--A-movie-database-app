import UIKit

class HomeViewController: UIViewController, CollectionViewTableViewCellDelegate {

    private enum Section: Int, CaseIterable {
        case trendingMovies
        case trendingTV
        case popular
        case upcoming
        case topRated
        
        var title: String {
            switch self {
            case .trendingMovies: return "Trending Movies"
            case .trendingTV: return "Trending TV"
            case .popular: return "Popular"
            case .upcoming: return "Upcoming Movies"
            case .topRated: return "Top Rated"
            }
        }
    }
    
    private var moviePreviewPresenter: MoviePreviewPresenter!
    private var selectedProfileImageName: String = "Profile1"
    private var headerView: HeroHeaderUIView?
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
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
        view.backgroundColor = .systemBackground
        moviePreviewPresenter = MoviePreviewPresenter(parentViewController: self)
        
        view.addSubview(homeFeedTable)
        view.addSubview(activityIndicator)
        
        setupConstraints()
        
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        configureHeaderView()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            homeFeedTable.topAnchor.constraint(equalTo: view.topAnchor),
            homeFeedTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeFeedTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeFeedTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureHeaderView() {
        headerView = HeroHeaderUIView(frame: .zero)
        homeFeedTable.tableHeaderView = headerView
        
        updateHeaderViewFrame()
        
        activityIndicator.startAnimating()
        NetworkManager.shared.fetchTrendingMovies { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let movies):
                    if let selectedMovie = movies.randomElement() {
                        self?.headerView?.configure(with: selectedMovie.title, posterPath: selectedMovie.posterPath)
                    }
                case .failure(let error):
                    self?.showError("Failed to load trending movies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateHeaderViewFrame() {
        guard let headerView = headerView else { return }
        headerView.frame.size = CGSize(width: view.bounds.width, height: 400)
        headerView.updateConstraintsForSize(view.bounds.size)
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let newSize = headerView.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        headerView.frame.size.height = newSize.height
        homeFeedTable.tableHeaderView = headerView
    }
    
    private func configureNavbar() {
        updateSelectedProfileImageName()
        let image = UIImage(named: "App1e")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: selectedProfileImageName)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(launchProfile))
        ]
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func updateSelectedProfileImageName() {
        selectedProfileImageName = UserDefaults.standard.string(forKey: "selectedProfileImage") ?? "Profile1"
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.headerView?.updateConstraintsForSize(size)
            self?.updateHeaderViewFrame()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let headerHeight = homeFeedTable.tableHeaderView?.frame.height ?? 0
        let threshold = headerHeight - (navigationController?.navigationBar.frame.height ?? 0)
        
        let appearance = navigationController?.navigationBar.standardAppearance
        if offsetY > threshold {
            appearance?.backgroundColor = .systemBackground
        } else {
            appearance?.backgroundColor = .clear
        }
    }
    
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, movie: Movie) {
        let viewModel = MoviePreviewViewModel(title: movie.title, overview: movie.overview, imagePath: movie.backdropPath)
        moviePreviewPresenter.presentDrawer(with: viewModel)
    }
    
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, tv: TVShow) {
        let viewModel = MoviePreviewViewModel(title: tv.name, overview: tv.overview, imagePath: tv.backdropPath)
        moviePreviewPresenter.presentDrawer(with: viewModel)
    }
    
    @objc private func launchProfile() {
        let profileVC = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        
        present(navController, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell,
              let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch section {
        case .trendingMovies:
            NetworkManager.shared.fetchTrendingMovies { result in
                switch result {
                case .success(let movies): cell.configure(with: movies)
                case .failure(let error): print(error.localizedDescription)
                }
            }
        case .trendingTV:
            NetworkManager.shared.fetchTrendingTVShows { result in
                switch result {
                case .success(let tvShows): cell.configure(with: tvShows)
                case .failure(let error): print(error.localizedDescription)
                }
            }
        case .popular:
            NetworkManager.shared.fetchPopular { result in
                switch result {
                case .success(let movies): cell.configure(with: movies)
                case .failure(let error): print(error.localizedDescription)
                }
            }
        case .upcoming:
            NetworkManager.shared.fetchUpcomingMovies { result in
                switch result {
                case .success(let movies): cell.configure(with: movies)
                case .failure(let error): print(error.localizedDescription)
                }
            }
        case .topRated:
            NetworkManager.shared.fetchTopRated { result in
                switch result {
                case .success(let movies): cell.configure(with: movies)
                case .failure(let error): print(error.localizedDescription)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
}

