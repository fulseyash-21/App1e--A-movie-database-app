import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ProfileImagePickerDelegate {

    private var selectedProfileImageName: String?
    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Morpheus"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Dream"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "person.fill"))
        icon.tintColor = .secondaryLabel
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -4),
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
        
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Data Source
    private let settings: [[(icon: String, title: String)]] = [
        [("gear", "Account Settings"), ("bell", "Notifications"), ("arrow.down.to.line", "Download Settings")],
        [("questionmark.circle", "Help & Support"), ("info.circle", "About")],
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        view.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(userTypeLabel)
        view.addSubview(tableView)
        view.addSubview(signOutButton)
        
        tableView.delegate = self
        tableView.dataSource = self

  
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapEditProfileImage))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        loadProfileImage()
        updateConstraints(to: self.view.bounds.size)
    }

    private func loadProfileImage() {
        if let savedImageName = UserDefaults.standard.string(forKey: "selectedProfileImage") {
            profileImageView.image = UIImage(named: savedImageName)
            selectedProfileImageName = savedImageName
        } else {
            profileImageView.image = UIImage(named: "Profile1")
            selectedProfileImageName = "Profile1"
        }
    }
    
    // MARK: - Actions
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapEditProfileImage() {
        let pickerVC = ProfileImagePickerViewController()
        pickerVC.delegate = self
        
        let navController = UINavigationController(rootViewController: pickerVC)
        if let sheet = navController.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("contentHeight")) { context in
                return pickerVC.preferredContentSize.height
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = customDetent.identifier
        }
        self.present(navController, animated: true, completion: nil)
    }

    // MARK: - ProfileImagePickerDelegate
    func didSelectProfileImage(imageName: String) {
        selectedProfileImageName = imageName
        profileImageView.image = UIImage(named: imageName)
        UserDefaults.standard.setValue(imageName, forKey: "selectedProfileImage")
    }
    
    // MARK: - Layout
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            let actualSize = self.view.bounds.size
            self.updateConstraints(to: actualSize)
        })
    }
    
    private func updateConstraints(to size: CGSize) {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()
        
        if size.width < size.height {
            activeConstraints = [
                profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                profileImageView.widthAnchor.constraint(equalToConstant: 120),
                profileImageView.heightAnchor.constraint(equalToConstant: 120),
                
                userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
                userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                userTypeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
                userTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                tableView.topAnchor.constraint(equalTo: userTypeLabel.bottomAnchor, constant: 20),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                signOutButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
                signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ]
        } else {
            activeConstraints = [
                profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
                profileImageView.widthAnchor.constraint(equalToConstant: 120),
                profileImageView.heightAnchor.constraint(equalToConstant: 120),
                
                userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
                userNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
                
                userTypeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
                userTypeLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
                
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                tableView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 50),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor),
                
                signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ]
        }
        NSLayoutConstraint.activate(activeConstraints)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let setting = settings[indexPath.section][indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = setting.title
        content.image = UIImage(systemName: setting.icon)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = settings[indexPath.section][indexPath.row]
        
        var title: String
        var sections: [SettingsBottomSheetViewController.SettingsSection]
        
        switch selectedItem.title {
        case "Account Settings":
            title = "Account Settings"
            sections = getAccountSettings()
        case "Notifications":
            title = "Notifications"
            sections = getNotificationSettings()
        case "Download Settings":
            title = "Download Settings"
            sections = getDownloadSettings()
        case "Help & Support":
            title = "Help & Support"
            sections = getHelpSettings()
        default:
            print("Selected: \(selectedItem.title)")
            return
        }

        let settingsVC = SettingsBottomSheetViewController(mainTitle: title, sections: sections)
        let navController = UINavigationController(rootViewController: settingsVC)
        
        if let sheet = navController.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("contentHeight")) { context in
                return settingsVC.preferredContentSize.height + 50.0
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = customDetent.identifier
        }
        
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Settings Data Providers
    private func getAccountSettings() -> [SettingsBottomSheetViewController.SettingsSection] {
        return [
            (header: "EMAIL PREFERENCES", items: [
                (icon: nil, title: "Email Notifications", accessoryType: .toggle, detailText: nil),
                (icon: nil, title: "Marketing Emails", accessoryType: .toggle, detailText: nil)
            ]),
            (header: "ACCOUNT ACTIONS", items: [
                (icon: nil, title: "Change Password", accessoryType: .disclosure, detailText: nil),
                (icon: nil, title: "Update Payment Method", accessoryType: .disclosure, detailText: nil),
                (icon: nil, title: "Clear Cache", accessoryType: .disclosure, detailText: nil)
            ]),
            (header: "DANGER ZONE", items: [
                (icon: nil, title: "Reset All Settings", accessoryType: .destructive, detailText: nil),
                (icon: nil, title: "Delete Account", accessoryType: .destructive, detailText: nil)
            ])
        ]
    }
    
    private func getNotificationSettings() -> [SettingsBottomSheetViewController.SettingsSection] {
        return [
            (header: "PUSH NOTIFICATIONS", items: [
                (icon: nil, title: "Enable Push Notifications", accessoryType: .toggle, detailText: nil)
            ]),
            (header: "EMAIL NOTIFICATIONS", items: [
                (icon: nil, title: "New Content Alerts", accessoryType: .toggle, detailText: nil),
                (icon: nil, title: "Marketing Updates", accessoryType: .toggle, detailText: nil)
            ]),
            (header: "NOTIFICATION TYPES", items: [
                (icon: "display", title: "New Episodes", accessoryType: .toggle, detailText: nil),
                (icon: "star", title: "Recommendations", accessoryType: .toggle, detailText: nil),
                (icon: "arrow.down.to.line", title: "Download Complete", accessoryType: .toggle, detailText: nil)
            ])
        ]
    }
    
    private func getDownloadSettings() -> [SettingsBottomSheetViewController.SettingsSection] {
        return [
            (header: "DOWNLOAD PREFERENCES", items: [
                (icon: nil, title: "Auto Download", accessoryType: .toggle, detailText: nil),
                (icon: nil, title: "WiFi Only Downloads", accessoryType: .toggle, detailText: nil)
            ]),
            (header: "VIDEO QUALITY", items: [
                (icon: nil, title: "Download Quality", accessoryType: .disclosure, detailText: "High")
            ]),
            (header: "STORAGE", items: [
                (icon: nil, title: "Downloaded Content", accessoryType: .detail, detailText: "2.3 GB"),
                (icon: nil, title: "Clear All Downloads", accessoryType: .destructive, detailText: nil)
            ])
        ]
    }
    
    private func getHelpSettings() -> [SettingsBottomSheetViewController.SettingsSection] {
        return [
            (header: "GET HELP", items: [
                (icon: "envelope", title: "Contact Support", accessoryType: .disclosure, detailText: nil),
                (icon: "questionmark.circle", title: "FAQ", accessoryType: .disclosure, detailText: nil),
                (icon: "exclamationmark.triangle", title: "Report an Issue", accessoryType: .disclosure, detailText: nil)
            ]),
            (header: "RESOURCES", items: [
                (icon: "hand.raised", title: "Privacy Policy", accessoryType: .disclosure, detailText: nil),
                (icon: "doc.text", title: "Terms of Service", accessoryType: .disclosure, detailText: nil)
            ])
        ]
    }
}

