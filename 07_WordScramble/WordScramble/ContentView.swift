//
//  ContentView.swift
//  WordScramble
//
//  Created by Benedict Neo on 1/22/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    private let customFont = "AvenirNext-Regular"
    private let primaryColor = Color.blue
    private let secondaryColor = Color.gray
    
    var body: some View {
        NavigationStack {
            VStack{
                TextField("Enter your word", text: $newWord)
                    .font(Font.custom(customFont, size: 18))
                    .padding()
                    .background(secondaryColor.opacity(0.1))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    
                List {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word).font(Font.custom(customFont, size: 18))
                        }
                        .transition(.slide)
                    }
                }

                Text("Your Score: \(score)")
                     .font(Font.custom(customFont, size: 24))
                     .foregroundColor(primaryColor)
                     .fontWeight(.bold)
                     .padding()
            }

            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New Word", action: startGame)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Too short", message: "use 3 or more letters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "use a new word!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "word not possible", message: "you can't spell this word from '\(rootWord)'!" )
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "don't make stuff up!")
            return
        }
        
        score += answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                newWord = ""
                usedWords.removeAll()
                score = 0
                
                return
            }
        }
        
        usedWords.removeAll()
        fatalError("Could not load start.txt from bundle")
    }
    
    
    func isOriginal(word: String) -> Bool {
        return word != rootWord && !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
