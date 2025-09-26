import UIKit

protocol ProfileImagePickerDelegate: AnyObject {
    func didSelectProfileImage(imageName: String)
}

class ProfileImagePickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    weak var delegate: ProfileImagePickerDelegate?

    private let images = (1...16).map { "Profile\($0)" }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select an Avatar"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ProfileImageCollectionViewCell.self, forCellWithReuseIdentifier: ProfileImageCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(collectionView)

        closeButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)

        collectionView.dataSource = self
        collectionView.delegate = self
        
        applyConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updatePreferredContentSize() {
        view.layoutIfNeeded()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let navBarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0
        let totalHeight = contentHeight + navBarHeight + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }

    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileImageCollectionViewCell.identifier, for: indexPath) as? ProfileImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageName = images[indexPath.row]
        cell.configure(with: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsPerRow: CGFloat = 4
        let totalHorizontalPadding = (cellsPerRow - 1) * 16 + 16 * 2
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let width = availableWidth / cellsPerRow
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedImageName = images[indexPath.row]
        delegate?.didSelectProfileImage(imageName: selectedImageName)
        dismiss(animated: true, completion: nil)
    }
}
