//
//  ContentView.swift
//  WeSplit
//
//  Created by Benedict Neo on 1/14/24.
//

import SwiftUI

struct ContentView: View {
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    @FocusState private var amountIsFocused: Bool
    
    private let minNumberOfPeople = 2
    
    var totalPerPerson: Double {
        let peopleCount = Double(numberOfPeople + minNumberOfPeople)
        let grandTotal = calculateTotalAmount(withTip: true)
        
        return peopleCount == 0 ? 0 : grandTotal / peopleCount
    }
    
    var totalAmount: Double {
        return calculateTotalAmount(withTip: true)
    }
    
    func calculateTotalAmount(withTip: Bool ) -> Double {
        let tipSelection = Double(tipPercentage)
        let tipValue = withTip ? checkAmount / 100 * tipSelection : 0
        
        return checkAmount + tipValue
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bill amount") {
                    TextField("Amount", value: $checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.numberPad)
                        .focused($amountIsFocused)
                }
                
                Section("How many people?") {
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(2..<30) {
                            Text("\($0) people")
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                
                Section("How much do you want to tip?") {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(0..<101) {
                            Text($0, format: .percent)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                
                Section("Total Amount") {
                    Text(totalAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .foregroundStyle(tipPercentage == 0 ? .red : .black)
                }
                
                Section("Amount per person") {
                    Text(totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
            }
            .navigationTitle("WeSplit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}

// render the code, only affect canvas
#Preview {
    ContentView()
}
