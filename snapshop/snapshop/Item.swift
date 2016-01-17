//
//  Item.swift
//  snapshop
//
//  Created by David on 1/16/16.
//  Copyright © 2016 David Zhang. All rights reserved.
//

import Foundation

class Item {
    var price: Double
    var count: Int
    var name: String
    var image: NSString
    init(d: NSDictionary) {
        self.name = d["name"] as! String
        self.price = d["price"] as! Double
        self.image = d["image"] as! String
        self.count = 1
    }
}