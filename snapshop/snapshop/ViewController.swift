import UIKit
import AVFoundation
import CNPPopupController
import Firebase

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CNPPopupControllerDelegate {
    
    let session: AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var highlightView: UIView = UIView()
    var scannedItems: UIButton = UIButton(type: .Custom)
    var checkout: UIButton = UIButton(type: .Custom)
    var data: NSDictionary = NSDictionary()
    var popupController: CNPPopupController?
    var shoppingCart: ShoppingCart = ShoppingCart()
    var dictionary: NSDictionary = NSDictionary()
    var pvc : PageViewController?

    let ref = Firebase(url: "https://snapshop.firebaseio.com")
    
    func showScannedItems() {
        pvc?.showCart()
    }
    
    func showCheckout() {
        pvc?.showCheckout()
    }

    func addTargetsToButtons() {
        self.scannedItems.addTarget(self, action: "showScannedItems", forControlEvents: .TouchUpInside)
        self.checkout.addTarget(self, action: "showCheckout", forControlEvents: .TouchUpInside)
    }

    func addItem() {
        shoppingCart.insert(dictionary)
        self.popupController?.dismissPopupControllerAnimated(true)
        self.session.startRunning()
    }
    
    func cancelItemInfo() {
        self.popupController?.dismissPopupControllerAnimated(true)
        self.session.startRunning()
    }
    
    func showItemInfo() {
        let view: UIView = UIView(frame: CGRectMake(0, 0, 0, 0))
        let name: UILabel = UILabel()
        let productImageView: UIImageView = UIImageView()
        name.textAlignment = .Center
        name.attributedText = NSAttributedString(string: dictionary["name"] as! String)
        let price: UILabel = UILabel()
        price.textAlignment = .Center
        if let p = dictionary["price"] {
            price.attributedText = NSAttributedString(string: "$ \(String(p))")
        }
        let checkmark: UIButton = UIButton(type: .Custom)
        if let image = UIImage(named: "Checkmark.png") {
            checkmark.setImage(image, forState: .Normal)
        }
        let cancel: UIButton = UIButton(type: .Custom)
        if let image = UIImage(named: "Cancel.png") {
            cancel.setImage(image, forState: .Normal)
        }
        checkmark.addTarget(self, action: "addItem", forControlEvents: UIControlEvents.TouchDown)
        cancel.addTarget(self, action: "cancelItemInfo", forControlEvents: UIControlEvents.TouchDown)
        if let url = NSURL(string: self.dictionary["image"] as! String) {
            if let data = NSData(contentsOfURL: url) {
                productImageView.image = UIImage(data: data)
            }
        }
        self.popupController = CNPPopupController(contents: [view, productImageView, name, price, checkmark, cancel])
        self.popupController!.delegate = self
        self.popupController?.presentPopupControllerAnimated(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.session.stopRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.session.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pvc = self.parentViewController as! PageViewController;
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            if (!(snapshot.value is NSNull)) {
                self.data = snapshot.value as! NSDictionary
            }
        }, withCancelBlock: { error in
            print(error.description)
        })
        
        // Select the color you want for the completed scan reticle
        self.highlightView.layer.borderColor = UIColor.greenColor().CGColor
        self.highlightView.layer.borderWidth = 3
        self.view.addSubview(self.highlightView)
        
        
        // For the sake of discussion this is the camera
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Create a nilable NSError to hand off to the next method.
        // Make sure to use the "var" keyword and not "let"
        var input : AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        // If our input is not nil then add it to the session, otherwise we're kind of done!
        if input != nil {
            session.addInput(input)
        }
        else {
            // This is fine for a demo, do something real with this in your app. :)
            print("Error: No input")
        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        session.addOutput(output)
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        
        scannedItems.tintColor = UIColor.whiteColor()
        
        if let image = UIImage(named: "ShoppingBag.png") {
            let image = image.imageWithRenderingMode(.AlwaysTemplate)
            scannedItems.setImage(image, forState: .Normal)
        }
        
        self.scannedItems.frame = CGRectMake(15, 15, 30, 30)
        
        // Add it to our controller's view as a subview.
        self.view.addSubview(self.scannedItems)
        
        checkout.tintColor = UIColor.whiteColor()
        
        if let image = UIImage(named: "Checkout.png") {
            let image = image.imageWithRenderingMode(.AlwaysTemplate)
            checkout.setImage(image, forState: .Normal)
        }
        
        self.checkout.frame = CGRectMake(325, 15, 30, 30)
        
        // Add it to our controller's view as a subview.
        self.view.addSubview(self.checkout)
        
        // Start the scanner. You'll have to end it yourself later.
        addTargetsToButtons()
        session.startRunning()
        
    }
    
    // This is called when we find a known barcode type with the camera.
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        
        var barCodeObject : AVMetadataObject!
        
        var detectionString : String!
        
        let barCodeTypes = [AVMetadataObjectTypeUPCECode,
            AVMetadataObjectTypeCode39Code,
            AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code,
            AVMetadataObjectTypeEAN8Code,
            AVMetadataObjectTypeCode93Code,
            AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code,
            AVMetadataObjectTypeQRCode,
            AVMetadataObjectTypeAztecCode
        ]
        
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        for metadata in metadataObjects {
            
            for barcodeType in barCodeTypes {
                
                if metadata.type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataMachineReadableCodeObject)
                    
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.session.stopRunning()
                    self.dictionary = self.data[detectionString] as! NSDictionary
                    showItemInfo()
                }
                
            }
        }
        
        self.highlightView.frame = highlightViewRect
        self.view.bringSubviewToFront(self.highlightView)
    }
}
