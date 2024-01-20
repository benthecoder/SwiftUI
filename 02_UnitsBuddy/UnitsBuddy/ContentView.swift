//
//  ContentView.swift
//  UnitsBuddy
//
//  Created by Benedict Neo on 1/15/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var inputUnit = "Celsius"
    @State private var outputUnit = "Fahrenheit"
    @State private var inputValue: Double = 0
    @FocusState private var isFocused: Bool
    
    var convertedValue: Double {
        switch inputUnit {
        case "Celsius":
            if outputUnit == "Fahrenheit" {
                return (inputValue * 9 / 5) + 32
            } else {
                return inputValue // Celsius to Celsius
            }
        case "Fahrenheit":
            if outputUnit == "Celsius" {
                return (inputValue - 32) * 5 / 9
            } else {
                return inputValue // Fahrenheit to Fahrenheit
            }
        default:
            return 0 // Default case, though it should never be reached
        }
    }
    
    private let units = ["Celsius", "Fahrenheit"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Choose input unit") {
                    Picker("Input unit", selection: $inputUnit) {
                        ForEach(units, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Choose output unit") {
                    Picker("Output unit", selection: $outputUnit) {
                        ForEach(units, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("What's your input value?") {
                    TextField("Input value", value: $inputValue, format: .number)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                }
                
                Section("Converted value") {
                    Text(convertedValue.formatted(.number.precision(.fractionLength(1))))
                }
            }
            .navigationTitle("UnitsBuddy")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
