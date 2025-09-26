import UIKit

class SettingsBottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Type Definitions
    
    public enum CellAccessory {
        case toggle
        case disclosure
        case detail
        case destructive
    }
    
    public typealias SettingItem = (icon: String?, title: String, accessoryType: CellAccessory, detailText: String?)
    public typealias SettingsSection = (header: String, items: [SettingItem])
    
    // MARK: - Properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var sections: [SettingsSection] = []
    
    // MARK: - Initialization
    
    init(mainTitle: String, sections: [SettingsSection]) {
        super.init(nibName: nil, bundle: nil)
        self.title = mainTitle
        self.sections = sections
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        applyConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    // MARK: - Layout
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updatePreferredContentSize() {
        let totalHeight = tableView.contentSize.height + (navigationController?.navigationBar.frame.height ?? 0) + view.safeAreaInsets.bottom + 40
        preferredContentSize = CGSize(width: view.bounds.width, height: totalHeight)
    }
    
    // MARK: - Actions
    
    @objc private func didTapDone() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        if let iconName = item.icon {
            content.image = UIImage(systemName: iconName)
        }
        cell.contentConfiguration = content
        
        switch item.accessoryType {
        case .toggle:
            let switchControl = UISwitch()
            cell.accessoryView = switchControl
            cell.selectionStyle = .none
        case .disclosure:
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = item.detailText
        case .detail:
            cell.selectionStyle = .none
            cell.detailTextLabel?.text = item.detailText
        case .destructive:
            cell.textLabel?.textColor = .systemRed
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        
        if selectedItem.accessoryType == .destructive || selectedItem.accessoryType == .disclosure {
            print("Selected: \(selectedItem.title)")
        }
    }
}

