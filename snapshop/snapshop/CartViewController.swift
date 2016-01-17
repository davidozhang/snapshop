import UIKit
import ImageLoader


class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var items : Array<Item> = []
    
    override func viewDidAppear(animated: Bool) {
        items = ShoppingCart.instance.getArray()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cartCell", forIndexPath: indexPath) as! CartTableViewCell
        
        let curItem = items[indexPath.row]
        cell.title.text = curItem.name
        cell.quantity.text = String(curItem.count)
        cell.label.layer.cornerRadius = 20;
        cell.label.clipsToBounds = true
        cell.label.load(curItem.image as String)
        cell.price.text = String(curItem.price * Double(curItem.count))
        
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }
}
    