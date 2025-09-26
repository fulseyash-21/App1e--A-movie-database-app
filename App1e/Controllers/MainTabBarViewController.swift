import UIKit

class MainTabBarViewController: UITabBarController {

    private enum TabBarItem {
        case home
        case upcoming
        case search
        case downloads

        var title: String {
            switch self {
            case .home: return "Home"
            case .upcoming: return "Coming Soon"
            case .search: return "Search"
            case .downloads: return "My List"
            }
        }

        var iconName: String {
            switch self {
            case .home: return "house"
            case .upcoming: return "play.circle"
            case .search: return "magnifyingglass"
            case .downloads: return "list.bullet"
            }
        }

        var viewController: UIViewController {
            let vc: UIViewController
            switch self {
            case .home:
                vc = HomeViewController()
            case .upcoming:
                vc = UpcomingViewController()
            case .search:
                vc = SearchViewController()
            case .downloads:
                vc = DownloadsViewController()
            }
            vc.tabBarItem.image = UIImage(systemName: iconName)
            vc.tabBarItem.title = title
            return UINavigationController(rootViewController: vc)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let viewControllers = [
            TabBarItem.home.viewController,
            TabBarItem.upcoming.viewController,
            TabBarItem.search.viewController,
            TabBarItem.downloads.viewController
        ]
        
        self.setViewControllers(viewControllers, animated: true)
        tabBar.tintColor = .label
    }
}
