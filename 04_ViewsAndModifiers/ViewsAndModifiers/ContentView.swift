//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Benedict Neo on 1/17/24.
//

import SwiftUI

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .titleStyle()
            .padding()
            .background(.red)
            .padding()
            .background(.blue)
            .padding()
            .background(.green)
            .padding()
            .background(.yellow)
    }
}

#Preview {
    ContentView()
}
