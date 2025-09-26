import UIKit
import WebKit
import UserNotifications

class MoviePreviewViewController: UIViewController {
    
    private var viewModel: MoviePreviewViewModel?
    private var activeConstraints: [NSLayoutConstraint] = []
    
    private let backdropView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let webView: WKWebView = {
        let wkWebView = WKWebView()
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        return wkWebView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add to list", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "play.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    private func updatePreferredContentSize() {
        let totalHeight = (backdropView.image?.size.height ?? 100) + (overviewLabel.frame.size.height) + (titleLabel.frame.size.height) + (navigationController?.navigationBar.frame.height ?? 0)
        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.updateConstraints(to: self.view.bounds.size)
        })
    }
    
    private func updateConstraints(to size: CGSize) {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()
        
        let isPortrait = size.width < size.height
        
        if isPortrait {
            activeConstraints = createPortraitConstraints()
        } else {
            activeConstraints = createLandscapeConstraints()
        }
        
        NSLayoutConstraint.activate(activeConstraints)
    }
    
    private func createPortraitConstraints() -> [NSLayoutConstraint] {
        return [
            backdropView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backdropView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backdropView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            backdropView.heightAnchor.constraint(equalTo: backdropView.widthAnchor, multiplier: 0.56),
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            webView.heightAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 0.56),
            
            titleLabel.topAnchor.constraint(equalTo: backdropView.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 180),
            downloadButton.heightAnchor.constraint(equalToConstant: 50),
            downloadButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            playButton.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -20)
        ]
    }
    
    private func createLandscapeConstraints() -> [NSLayoutConstraint] {
        return [
            backdropView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backdropView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backdropView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            backdropView.heightAnchor.constraint(equalTo: backdropView.widthAnchor, multiplier: 0.56),
            
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            webView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            webView.heightAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 0.56),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backdropView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: backdropView.trailingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 180),
            downloadButton.heightAnchor.constraint(equalToConstant: 50),
            downloadButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            playButton.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            playButton.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -20)
        ]
    }
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        view.addSubview(backdropView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(downloadButton)
        view.addSubview(playButton)
        view.addSubview(webView)
        
        webView.isHidden = true
        updateConstraints(to: self.view.bounds.size)
        
        downloadButton.addTarget(self, action: #selector(didTapDownload), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
    }
    
    public func configure(with model: MoviePreviewViewModel) {
        self.viewModel = model
        titleLabel.text = model.title
        overviewLabel.text = model.overview
        
        backdropView.sd_setImage(with: model.imageURL, completed: nil)
        
        fetchYouTubeVideo()
    }
    
    private func fetchYouTubeVideo() {
        guard let movieName = titleLabel.text else { return }
        NetworkManager.shared.getYouTubeVideoId(with: movieName) { [weak self] result in
            switch result {
            case .success(let items):
                guard let videoId = items.first?.id.videoId else { return }
                let embedHTML = """
                    <html><body style="margin:0px;padding:0px;">
                    <iframe width="100%" height="100%" src="https://www.youtube.com/embed/\(videoId)?playsinline=1" frameborder="0" allowfullscreen></iframe>
                    </body></html>
                    """
                DispatchQueue.main.async {
                    self?.webView.loadHTMLString(embedHTML, baseURL: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func playTrailer() {
        webView.isHidden = false
        backdropView.isHidden = true
    }
    
    @objc private func didTapDownload() {
        guard let model = viewModel else { return }

        var downloads = UserDefaults.standard.array(forKey: "ListedMovies") as? [[String: String]] ?? []
        
        if downloads.contains(where: { $0["title"] == model.title }) {
            showAlert(title: "Already in List", message: "\(model.title) is already in your list.")
            return
        }

        let info: [String: String] = [
            "title": model.title,
            "overview": model.overview,
            "imagePath": model.imagePath ?? ""
        ]
        
        downloads.append(info)
        UserDefaults.standard.set(downloads, forKey: "ListedMovies")
        
        scheduleNotification(for: model.title)
        showAlert(title: "Added to List", message: "\(model.title) has been added to your list.")
    }
    
    private func scheduleNotification(for title: String) {
        let content = UNMutableNotificationContent()
        content.title = "Added to List: \(title)"
        content.body = "This item is now available in your list."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "ListAdd-\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

