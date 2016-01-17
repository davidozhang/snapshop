//
//  CheckoutViewController.swift
//  snapshop
//
//  Created by Chris Thi on 2016-01-16.
//  Copyright © 2016 David Zhang. All rights reserved.
//

import UIKit
import Braintree

class CheckoutViewController: UIViewController, BTDropInViewControllerDelegate {

    var braintree: Braintree?

    @IBOutlet var subtotal: UILabel!
    @IBOutlet var tax: UILabel!
    @IBOutlet var total: UILabel!
    @IBOutlet var payButton: UIButton!
    
    
    var shoppingCart: ShoppingCart = ShoppingCart.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.backgroundColor = UIColor(red: 0.5, green: 0.9, blue: 0.1, alpha: 1)
        payButton.addTarget(self, action: "tappedPayButton", forControlEvents: UIControlEvents.TouchDown)
        payButton.enabled = false
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
            
            // Initialize `Braintree` once per checkout session
            self.braintree = Braintree(clientToken: clientToken!)
            
            self.payButton.enabled = true
            // As an example, you may wish to present our Drop-in UI at this point.
            // Continue to the next section to learn more...
            }.resume()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        let subtotalAmount: Double = shoppingCart.getSubtotal()
        let taxAmount: Double = subtotalAmount * 0.13
        let totalAmount: Double = subtotalAmount + taxAmount
        subtotal.text = "$ " + String(format: "%.2f",subtotalAmount)
        tax.text = "$ " + String(format: "%.2f",taxAmount)
        total.text = "$ " + String(format: "%.2f",totalAmount)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedPayButton() {
        // If you haven't already, create and retain a `Braintree` instance with the client token.
        // Typically, you only need to do this once per session.
        //braintree = Braintree(clientToken: aClientToken)
        
        // Create a BTDropInViewController
        let dropInViewController = braintree!.dropInViewControllerWithDelegate(self)
        
        // This is where you might want to customize your Drop-in. (See below.)
        dropInViewController.view.tintColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 0.7)
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "userDidCancelPayment")
        
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewController(viewController: BTDropInViewController!, didSucceedWithPaymentMethod paymentMethod: BTPaymentMethod!) {
        //postNonceToServer(paymentMethod.nonce) // Send payment method nonce to your server
        dismissViewControllerAnimated(true, completion: nil)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let thankYouController = sb.instantiateViewControllerWithIdentifier("thankYouViewController") as? ThankYouViewController
        self.presentViewController(thankYouController!, animated: true, completion: nil)
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
