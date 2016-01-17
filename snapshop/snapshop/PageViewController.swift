import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    var cameraController = ViewController()
    var cartController : CartViewController?
    var checkoutController : CheckoutViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self;
        
        loadControllers()
        
        self.setViewControllers([cameraController], direction: .Forward, animated: true, completion: nil)
    }
    
    func showCart() {
        self.setViewControllers([cartController!], direction: .Reverse, animated: true, completion: nil)
    }
    
    func showCheckout() {
        self.setViewControllers([checkoutController!], direction: .Forward, animated: true, completion: nil)
    }
    
    func loadControllers() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        cartController = sb.instantiateViewControllerWithIdentifier("cartViewController") as? CartViewController
        checkoutController = sb.instantiateViewControllerWithIdentifier("checkoutViewController") as? CheckoutViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? CartViewController {
            return cameraController;
        } else if let _ = viewController as? ViewController {
            return checkoutController;
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let _ = viewController as? CheckoutViewController {
            return cameraController;
        } else if let _ = viewController as? ViewController {
            return cartController;
        }
        return nil
    }
}
