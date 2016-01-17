//
//  ShoppingCart.swift
//  snapshop
//
//  Created by David on 1/16/16.
//  Copyright © 2016 David Zhang. All rights reserved.
//

import Foundation

class ShoppingCart {
    static let instance = ShoppingCart()
    
    var cart: Array<Item>

    init() {
        cart = Array<Item>()
    }
    
    func getArray() -> Array<Item> {
        return cart
    }

    func getSubtotal() -> Double {
        var sum = 0.0
        for (index, element) in cart.enumerate() {
            sum += Double(element.price * Double(element.count))
        }
        return sum
    }
    
    func insert(n: NSDictionary) {
        for (index, element) in cart.enumerate() {
            if element.name == n["name"] as? String {
                element.count += 1
                return
            }
        }
        cart.append(Item(d: n))
    }
}