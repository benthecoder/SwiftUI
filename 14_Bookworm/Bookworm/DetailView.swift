//
//  DetailView.swift
//  Bookworm
//
//  Created by Benedict Neo on 2/20/24.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteAlert = false
    
    let book: Book
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomTrailing) {
                Image(book.genre)
                    .resizable()
                    .scaledToFit()
                
                Text(book.genre.uppercased())
                    .font(.caption)
                    .fontWeight(.black)
                    .padding(8)
                    .foregroundStyle(.white)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                    .offset(x: -5, y: -5)
            }
            
            Text(book.author)
                .font(.title)
                .foregroundStyle(.secondary)
            
            Text(book.review)
                .padding()
            
            RatingView(rating: .constant(book.rating))
                .font(.largeTitle)
            
            Text("Added on \(book.dateAdded.formatted(date: .abbreviated, time: .shortened))")
                .padding(.top, 20)
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .alert("Delete Book", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive, action: deleteBook)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure?")
        }
        .toolbar {
            Button("delete this book", systemImage: "trash") {
                showingDeleteAlert = true
            }
        }
    }
    
    func deleteBook() {
        modelContext.delete(book)
        dismiss()
    }
}

#Preview {
    do {
        // model configuration
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // model container
        let container = try ModelContainer(for: Book.self, configurations: config)
        // create Book
        let example = Book(title: "test", author: "Virginia Woolf", genre: "Fantasy", review: "awesome book", rating: 5)
    
        return DetailView(book: example)
            .modelContainer(container)

    } catch {
        return Text("failed to create preview: \(error.localizedDescription)")
    }
}
