import UIKit
import ImageLoader


class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var arr : Array<Item>?
    
    override func viewDidAppear(animated: Bool) {
        arr = ShoppingCart.instance.getArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cartCell", forIndexPath: indexPath) as! CartTableViewCell
        
        let curItem = arr![indexPath.row];
    
        cell.title.text = curItem.name
        cell.quantity.text = String(curItem.count)
        cell.price.text = String(curItem.price)
        cell.label.layer.cornerRadius = 20
        cell.label.clipsToBounds = true
        
        cell.label.load(curItem.image as String)
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (arr != nil) {
            return (arr?.count)!
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
}
    