import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {
    static let identifier = "MovieTableViewCell"

    private let moviePosterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.medium
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let movieTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(moviePosterImageView)
        contentView.addSubview(movieTitleLabel)
        NSLayoutConstraint.activate([
            moviePosterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            moviePosterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            moviePosterImageView.widthAnchor.constraint(equalToConstant: 100),
            moviePosterImageView.heightAnchor.constraint(equalToConstant: 130),

            movieTitleLabel.leadingAnchor.constraint(equalTo: moviePosterImageView.trailingAnchor, constant: 16),
            movieTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            movieTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            movieTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with model: MovieViewModel) {
        movieTitleLabel.text = model.title
        moviePosterImageView.sd_setImage(with: model.posterURL, completed: nil)
    }
}
