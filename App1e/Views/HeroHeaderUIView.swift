import UIKit
import SDWebImage

class HeroHeaderUIView: UIView {
    
    private var activeConstraints: [NSLayoutConstraint] = []
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Info", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let myListButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ My List", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(posterImageView)
        addSubview(titleLabel)
        addSubview(playButton)
        addSubview(myListButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateConstraintsForSize(_ size: CGSize) {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()
        
        subviews.forEach { view in
            if view is UIStackView {
                view.removeFromSuperview()
            }
        }
        
        if size.width < size.height {
            // Portrait Layout
            if !subviews.contains(posterImageView) { addSubview(posterImageView) }
            if !subviews.contains(titleLabel) { addSubview(titleLabel) }
            if !subviews.contains(playButton) { addSubview(playButton) }
            if !subviews.contains(myListButton) { addSubview(myListButton) }
            
            activeConstraints = [
                posterImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                posterImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                posterImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.54),
                posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.5),
                
                titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
                titleLabel.heightAnchor.constraint(equalToConstant: 50),

                playButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                playButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -6),
                playButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35),
                playButton.heightAnchor.constraint(equalToConstant: 36),
                
                myListButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 6),
                myListButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
                myListButton.widthAnchor.constraint(equalTo: playButton.widthAnchor),
                myListButton.heightAnchor.constraint(equalTo: playButton.heightAnchor),
                
                myListButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
            ]
        } else {
            // Landscape Layout
            let buttonStack = UIStackView(arrangedSubviews: [playButton, myListButton])
            buttonStack.axis = .horizontal
            buttonStack.spacing = 12
            buttonStack.distribution = .fillEqually
            
            let contentStack = UIStackView(arrangedSubviews: [titleLabel, buttonStack])
            contentStack.axis = .vertical
            contentStack.spacing = 12
            contentStack.alignment = .leading
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            
            let mainStack = UIStackView(arrangedSubviews: [posterImageView, contentStack])
            mainStack.axis = .horizontal
            mainStack.spacing = 20
            mainStack.alignment = .center
            mainStack.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(mainStack)
            
            activeConstraints = [
                mainStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
                mainStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
                mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
                
                posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 2.0/3.0),
                
                playButton.widthAnchor.constraint(equalToConstant: 120),
                myListButton.widthAnchor.constraint(equalToConstant: 120),
                playButton.heightAnchor.constraint(equalToConstant: 36)
            ]
        }
        
        NSLayoutConstraint.activate(activeConstraints)
    }
    
    public func configure(with title: String, posterPath: String?) {
        titleLabel.text = title
        if let posterPath = posterPath, let url = URL(string: "\(Constants.imageBaseURL)\(posterPath)") {
            posterImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        } else {
            posterImageView.image = UIImage(systemName: "photo")
        }
    }
}
