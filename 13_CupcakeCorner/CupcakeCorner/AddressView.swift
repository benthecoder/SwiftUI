//
//  AddressView.swift
//  CupcakeCorner
//
//  Created by Benedict Neo on 2/15/24.
//

import SwiftUI

struct AddressView: View {
    @Bindable var order: Order
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $order.name)
                TextField("Street Address", text: $order.streetAddress)
                TextField("City", text: $order.city)
                TextField("Zip", text: $order.zip)
            }

            Section {
                NavigationLink("Check out") {
                    CheckoutView(order: order)
                }
                .disabled(!order.hasValidAddress)
            }
        }
        .navigationTitle("Delivery details")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            order.saveAddressToUserDefaults()
        }
    }
}

#Preview {
    AddressView(order: Order())
}
