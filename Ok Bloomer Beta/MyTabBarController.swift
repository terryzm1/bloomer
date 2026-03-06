import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Access the tab bar's view controllers
        if let viewControllers = viewControllers,
           let viewController = viewControllers[1] as? ViewController,
           let powerViewController = viewControllers[0] as? PowerViewController {
            
            viewController.delegate = powerViewController
            
        }
    }
}
