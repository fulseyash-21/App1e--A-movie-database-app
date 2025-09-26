import UIKit

class MoviePreviewPresenter {

    private weak var parentViewController: UIViewController?
    private var drawerViewController: MoviePreviewViewController?
    private var topConstraint: NSLayoutConstraint?
    private var isDrawerOpen = false
    
    private let drawerAnimationOffset: CGFloat = 1000
    private let drawerSnapThreshold: CGFloat = 300
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    public func presentDrawer(with viewModel: MoviePreviewViewModel) {
        
        let movieVC = MoviePreviewViewController()
        let navController = UINavigationController(rootViewController: movieVC)
        
        if let sheet = navController.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("contentHeight")) { context in
                return movieVC.preferredContentSize.height + 50
            }
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        movieVC.configure(with: viewModel)
        parentViewController?.present(navController, animated: true, completion: nil)
        
        // Alternative presentation style using an upside-down drawer.
        // presentUpsideDownDrawer(with: viewModel)
    }

    private func presentUpsideDownDrawer(with viewModel: MoviePreviewViewModel) {
        guard let parentVC = parentViewController, let parentView = parentVC.view else { return }

        if let existingDrawer = self.drawerViewController {
            existingDrawer.configure(with: viewModel)
            return
        }
        
        let drawerVC = MoviePreviewViewController()
        drawerVC.configure(with: viewModel)
        self.drawerViewController = drawerVC

        parentVC.addChild(drawerVC)
        parentView.addSubview(drawerVC.view)
        drawerVC.didMove(toParent: parentVC)

        drawerVC.view.translatesAutoresizingMaskIntoConstraints = false
        drawerVC.view.layer.cornerRadius = 20
        drawerVC.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        topConstraint = drawerVC.view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: -drawerAnimationOffset)
        
        NSLayoutConstraint.activate([
            topConstraint!,
            drawerVC.view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            drawerVC.view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            drawerVC.view.bottomAnchor.constraint(lessThanOrEqualTo: parentView.bottomAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        drawerVC.view.addGestureRecognizer(panGesture)
        
        DispatchQueue.main.async {
            self.toggleDrawer(open: true)
        }
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        guard let parentView = parentViewController?.view else { return }
        let translation = gesture.translation(in: parentView)
        
        if gesture.state == .changed {
            let newConstant = min(0, translation.y)
            self.topConstraint?.constant = newConstant
        }
        
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: parentView)
            guard let currentConstant = self.topConstraint?.constant else { return }

            if velocity.y < -1200 || currentConstant < -drawerSnapThreshold {
                toggleDrawer(open: false)
            } else {
                toggleDrawer(open: true)
            }
        }
    }
    
    private func toggleDrawer(open: Bool) {
        guard let parentView = parentViewController?.view else { return }
        isDrawerOpen = open
        let finalConstant = open ? 0 : -drawerAnimationOffset
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut,
            animations: {
                self.topConstraint?.constant = finalConstant
                parentView.layoutIfNeeded()
            },
            completion: { [weak self] (isFinished) in
                guard let self = self, isFinished, !open else { return }
                
                DispatchQueue.main.async {
                    self.drawerViewController?.willMove(toParent: nil)
                    self.drawerViewController?.view.removeFromSuperview()
                    self.drawerViewController?.removeFromParent()
                    self.drawerViewController = nil
                    self.topConstraint = nil
                }
            }
        )
    }
}
