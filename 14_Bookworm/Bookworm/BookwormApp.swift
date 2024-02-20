//
//  BookwormApp.swift
//  Bookworm
//
//  Created by Benedict Neo on 2/19/24.
//

import SwiftUI
import SwiftData

@main
struct BookwormApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Book.self)
    }
}
