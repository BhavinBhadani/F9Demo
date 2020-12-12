import UIKit

@objc public extension UIViewController {
    @discardableResult
    func showWaitOverlay() -> UIView {
        return LoadingOverlays.showCenteredWaitOverlay(self.view)
    }

    func removeAllOverlays() {
        LoadingOverlays.removeAllOverlaysFromView(self.view)
    }
}

open class LoadingOverlays: NSObject {
    // Some random number
    static let containerViewTag = 456987123
    static let cornerRadius = CGFloat(10)
    static let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    
    open class Utils {
        public static func centerViewInSuperview(_ view: UIView) {
            assert(view.superview != nil, "`view` should have a superview")
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: view.superview!.centerXAnchor, constant: 0),
                view.centerYAnchor.constraint(equalTo: view.superview!.centerYAnchor, constant: 0),
                view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            ])
        }
    }
    
    // MARK: Blocking
    @discardableResult
    open class func showBlockingWaitOverlay() -> UIView {
        let blocker = addMainWindowBlocker()
        showCenteredWaitOverlay(blocker)
        return blocker
    }
    
    open class func removeAllBlockingOverlays() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("could not get scene delegate ")
        }
        let window = sceneDelegate.window!
        removeAllOverlaysFromView(window)
    }
    
    // MARK: Non-blocking
    @discardableResult
    open class func showCenteredWaitOverlay(_ parentView: UIView) -> UIView {
        let ai = UIActivityIndicatorView(style: .large)
        ai.startAnimating()
        
        let containerViewRect = CGRect(
            x: 0,
            y: 0,
            width: ai.frame.size.width * 2,
            height: ai.frame.size.height * 2
        )
        
        let containerView = UIView(frame: containerViewRect)
        
        containerView.tag = containerViewTag
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = backgroundColor
        containerView.center = CGPoint(
            x: parentView.bounds.size.width/2,
            y: parentView.bounds.size.height/2
        )
        
        ai.center = CGPoint(
            x: containerView.bounds.size.width/2,
            y: containerView.bounds.size.height/2
        )
        
        containerView.addSubview(ai)
        
        parentView.addSubview(containerView)
        
        Utils.centerViewInSuperview(containerView)
        
        return containerView
    }
    
    open class func removeAllOverlaysFromView(_ parentView: UIView) {
        parentView.subviews
            .filter { $0.tag == containerViewTag }
            .forEach { $0.removeFromSuperview() }
    }
    
    fileprivate class func addMainWindowBlocker() -> UIView {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            fatalError("could not get scene delegate ")
        }
        let window = sceneDelegate.window!
        
        let blocker = UIView(frame: window.bounds)
        blocker.backgroundColor = backgroundColor
        blocker.tag = containerViewTag
        
        blocker.translatesAutoresizingMaskIntoConstraints = false
        
        window.addSubview(blocker)
        
        let viewsDictionary = ["blocker": blocker]
        
        // Add constraints to handle orientation change
        let constraintsV = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[blocker]-0-|",
            options: [],
            metrics: nil,
            views: viewsDictionary
        )
        
        let constraintsH = NSLayoutConstraint.constraints(
            withVisualFormat: "|-0-[blocker]-0-|",
            options: [],
            metrics: nil,
            views: viewsDictionary
        )
        
        window.addConstraints(constraintsV + constraintsH)
        
        return blocker
    }
}
