//
//  AddView.swift
//  10_iExpense
//
//  Created by Benedict Neo on 2/7/24.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    var expenses: Expenses
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
        
    var body: some View {
        NavigationStack{
            Text("Add new expense")
                .font(.headline)
                .fontWeight(.bold)
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    Text("Personal").tag("Personal")
                    Text("Business").tag("Business")
                }
                TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
            }
            .toolbar {
                Button("Save") {
                    let item = ExpenseItem(name: name, type: type, amount: amount)
                    expenses.items.append(item)
                    dismiss()
                }
            }

        }
        .colorScheme(.dark)
    }
}

#Preview {
    AddView(expenses: Expenses())
}
