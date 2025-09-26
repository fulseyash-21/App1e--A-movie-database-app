import UIKit

class DownloadsViewController: UIViewController {

    private struct DownloadedMovie {
        let title: String
        let overview: String
        let imagePath: String
    }

    private var downloadedMovies: [DownloadedMovie] = []
    private var moviePreviewPresenter: MoviePreviewPresenter!

    private let downloadsTable: UITableView = {
        let table = UITableView()
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My List"
        view.backgroundColor = .systemBackground
        view.addSubview(downloadsTable)
        
        moviePreviewPresenter = MoviePreviewPresenter(parentViewController: self)

        setupConstraints()
        setupEmptyStateView()

        downloadsTable.delegate = self
        downloadsTable.dataSource = self

        fetchDownloads()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            downloadsTable.topAnchor.constraint(equalTo: view.topAnchor),
            downloadsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            downloadsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            downloadsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        let emptyLabel = UILabel(frame: downloadsTable.bounds)
        emptyLabel.text = "Your list is empty."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        downloadsTable.backgroundView = emptyLabel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDownloads()
    }

    private func fetchDownloads() {
        let stored = UserDefaults.standard.array(forKey: "ListedMovies") as? [[String: String]] ?? []
        downloadedMovies = stored.compactMap { dict in
            guard let title = dict["title"], let overview = dict["overview"], let imagePath = dict["imagePath"] else { return nil }
            return DownloadedMovie(title: title, overview: overview, imagePath: imagePath)
        }
        downloadsTable.reloadData()
        downloadsTable.backgroundView?.isHidden = !downloadedMovies.isEmpty
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        let movie = downloadedMovies[indexPath.row]
        cell.configure(with: MovieViewModel(title: movie.title, posterPath: movie.imagePath))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let movie = downloadedMovies[indexPath.row]
        let viewModel = MoviePreviewViewModel(
            title: movie.title,
            overview: movie.overview,
            imagePath: movie.imagePath
        )
        moviePreviewPresenter.presentDrawer(with: viewModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            downloadedMovies.remove(at: indexPath.row)
            
            let updatedDownloads = downloadedMovies.map { ["title": $0.title, "overview": $0.overview, "imagePath": $0.imagePath] }
            UserDefaults.standard.set(updatedDownloads, forKey: "ListedMovies")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            downloadsTable.backgroundView?.isHidden = !downloadedMovies.isEmpty
        }
    }
}

