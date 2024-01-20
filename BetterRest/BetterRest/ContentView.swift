//
//  ContentView.swift
//  BetterRest
//
//  Created by Benedict Neo on 1/20/24.
//

import SwiftUI
import CoreML


extension Color {
    static let neuFormBackground = Color(hex: "e0e0e3")
    static let mainBackground = Color(hex: "d1d3d4")

    static let dropShadow = Color.black.opacity(0.2)
    static let dropLight = Color.white
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}

struct NeumorphicButton: View {
    var text: String
    var action: () -> Void
    @State private var isPressed: Bool = false
    
    var shadow: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .shadow(color: Color.dropLight, radius: isPressed ? 7 : 10, x: isPressed ? -5 : -10, y: isPressed ? -5 : -10)
            .shadow(color: Color.dropShadow, radius: isPressed ? 7 : 10, x: isPressed ? 5 : 10, y: isPressed ? 5 : 10)
            .blendMode(.overlay)
    }
    
    var body: some View {
        Button(action: togglePressed) {
            Text(text)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .foregroundColor(.secondary)
                .padding()
                .background(
                    ZStack {
                        shadow
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.neuFormBackground)
                            .shadow(color: Color.dropLight, radius: 10, x: -8, y: -8)
                            .shadow(color: Color.dropShadow, radius: 10, x: 8, y: 8)
                    }
                )
                .scaleEffect(isPressed ? 0.98 : 1)
                .foregroundColor(.primary)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
    }
    
    private func togglePressed() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
            action()
        }
    }
}




struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        VStack(spacing: 17) {
                            neumorphicFormSection(title: "When do you want to wake up?") {
                                DatePicker("", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                            }
                            
                            neumorphicFormSection(title: "Desired amount of sleep") {
                                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                                    Text("\(sleepAmount.formatted()) hours")
                                }
                            }
                            
                            neumorphicFormSection(title: "Daily coffee intake") {
                                Stepper(value: $coffeeAmount, in: 1...20) {
                                    Text("^[\(coffeeAmount) cup](inflect: true)")
                                }
                            }
                        }
                        .padding(.top, -30)

                        
                        Spacer()
                        
                        NeumorphicButton(text: "Calculate", action: calculateBedtime)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("BetterRest")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .fontDesign(.monospaced)
                    }
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
            }
        }
    }


    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepPredictor(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let pred = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            
            let sleepTime = wakeUp - pred.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Something went wrong with the prediction"
        }
        
        showingAlert = true
    }
    
    @ViewBuilder
    private func neumorphicFormSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            content()
                .fontDesign(.monospaced)
                .fontWeight(.bold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.neuFormBackground)
                .shadow(color: Color.dropLight, radius: 10, x: -8, y: -8)
                .shadow(color: Color.dropShadow, radius: 10, x: 8, y: 8)
        )
        .padding(.horizontal, 20)
    }
}


#Preview {
    ContentView()
}
