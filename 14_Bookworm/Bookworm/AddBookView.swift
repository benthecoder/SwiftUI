//
//  AddBookView.swift
//  Bookworm
//
//  Created by Benedict Neo on 2/19/24.
//

import SwiftUI
import SwiftData

struct AddBookView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var rating = 3
    @State private var genre = "Fantasy"
    @State private var review = ""
    
    @State private var showingAlert = false
    
    let genres = ["Fantasy", "Horror", "Kids", "Mystery", "Poetry", "Romance", "Thriller"]
    
    var isFormValid: Bool {
        !title.isEmpty && !author.isEmpty && genres.contains(genre)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name of book", text: $title)
                        .autocorrectionDisabled()
                    TextField("Author's Name", text: $author)
                        .autocorrectionDisabled()
                    
                    Picker("Genre", selection: $genre) {
                        ForEach(genres, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section("Write a review") {
                    TextEditor(text: $review)
                    RatingView(rating: $rating)
                }
                
                Section {
                    Button("Save") {
                        if isFormValid {
                            let newBook = Book(title: title, author: author, genre: genre, review: review, rating: rating)
                            
                            modelContext.insert(newBook)
                            dismiss()
                        } else {
                            showingAlert = true
                        }
                    }
                    .disabled(!isFormValid)
                    .alert("missing information", isPresented: $showingAlert) {
                        Button("Ok", role: .cancel) {}
                    } message: {
                        Text("Please fill in all the details")
                    }
                }
            }
            .navigationTitle("Add a book")
        }
        .colorScheme(.dark)
    }
}

#Preview {
    AddBookView()
}
