//
//  Order.swift
//  CupcakeCorner
//
//  Created by Benedict Neo on 2/15/24.
//

import Foundation

@Observable
class Order: Codable {
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _city = "city"
        case _streetAddress = "streetAddress"
        case _zip = "zip"
    }

    
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]


    var type = 0
    var quantity = 3

    var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    
    var extraFrosting = false
    var addSprinkles = false
    
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    func saveAddressToUserDefaults() {
        UserDefaults.standard.set(name, forKey: "OrderName")
        UserDefaults.standard.set(streetAddress, forKey: "OrderStreetAddress")
        UserDefaults.standard.set(city, forKey: "OrderCity")
        UserDefaults.standard.set(zip, forKey: "OrderZip")
    }
    
    func loadAddressFromUserDefaults() {
        name = UserDefaults.standard.string(forKey: "OrderName") ?? ""
        streetAddress = UserDefaults.standard.string(forKey: "OrderStreetAddress") ?? ""
        city = UserDefaults.standard.string(forKey: "OrderCity") ?? ""
        zip = UserDefaults.standard.string(forKey: "OrderZip") ?? ""
    }
    
    var hasValidAddress: Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty ||
            streetAddress.trimmingCharacters(in: .whitespaces).isEmpty ||
            city.trimmingCharacters(in: .whitespaces).isEmpty ||
            zip.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }

        return true
    }
    
    var cost: Double {
        // $2 per cake
        var cost = Double(quantity) * 2

        // complicated cakes cost more
        cost += (Double(type) / 2)

        // $1/cake for extra frosting
        if extraFrosting {
            cost += Double(quantity)
        }

        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Double(quantity) / 2
        }

        return cost
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "SavedOrder")
        }
    }

    static func loadFromUserDefaults() -> Order? {
        if let savedOrder = UserDefaults.standard.object(forKey: "SavedOrder") as? Data {
            if let decodedOrder = try? JSONDecoder().decode(Order.self, from: savedOrder) {
                return decodedOrder
            }
        }
        return nil // Return a default value or nil if the order cannot be loaded
    }
    
    init() {
        loadAddressFromUserDefaults()
    }
}
