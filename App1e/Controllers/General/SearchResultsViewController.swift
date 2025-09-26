import UIKit

class SearchResultsViewController: UIViewController {

    public var movies: [Movie] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.searchResultsCollectionView.reloadData()
                self?.searchResultsCollectionView.backgroundView?.isHidden = !(self?.movies.isEmpty ?? true)
            }
        }
    }

    private var moviePreviewPresenter: MoviePreviewPresenter!

    private let topResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Results"
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let searchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let sidePadding: CGFloat = 16
        let interItemSpacing: CGFloat = 8
        let cellsPerRow: CGFloat = 3

        let totalSpacing = (cellsPerRow - 1) * interItemSpacing + (2 * sidePadding)
        let availableWidth = UIScreen.main.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / cellsPerRow)

        layout.itemSize = CGSize(width: itemWidth, height: 170)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: 16, left: sidePadding, bottom: 16, right: sidePadding)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(topResultsLabel)
        view.addSubview(searchResultsCollectionView)
        
        moviePreviewPresenter = MoviePreviewPresenter(parentViewController: self)
        setupEmptyStateView()

        NSLayoutConstraint.activate([
            topResultsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            topResultsLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -18),

            searchResultsCollectionView.topAnchor.constraint(equalTo: topResultsLabel.bottomAnchor, constant: 0),
            searchResultsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
    }

    private func setupEmptyStateView() {
        let emptyLabel = UILabel(frame: searchResultsCollectionView.bounds)
        emptyLabel.text = "No results found."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        searchResultsCollectionView.backgroundView = emptyLabel
        searchResultsCollectionView.backgroundView?.isHidden = true
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }
        let movie = movies[indexPath.row]
        cell.configure(with: movie.posterPath ?? "")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        let viewModel = MoviePreviewViewModel(
            title: movie.title,
            overview: movie.overview,
            imagePath: movie.backdropPath
        )
        moviePreviewPresenter.presentDrawer(with: viewModel)
    }
}

