//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Benedict Neo on 1/16/24.
//

import SwiftUI

struct FlagView: View {
    var image: String
    
    var body: some View {
        Image(image)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    @State private var countries = ["US", "UK", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "France", "Ukraine", "Estonia"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var userScore = 0
    @State private var questionCount = 0

    @State private var showingScore = false
    @State private var showFinalScore = false
    @State private var scoreTitle = ""

    
    
    var body: some View {
        ZStack{
            RadialGradient(stops: [
                .init(color: Color(red: 0.18, green: 0.19, blue: 0.57), location: 0.3), // Ocean Blue
                .init(color: Color(red: 0.90, green: 0.30, blue: 0.23), location: 0.3)  // Sunset Red
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()

            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) {number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagView(image: countries[number])
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(userScore)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion) 
        } message: {
            Text("Your score is \(userScore)")
        }
        .alert("Game Over", isPresented: $showFinalScore) {
            Button("Restart", action: resetGame)
        } message: {
            Text("Your final score is \(userScore)")
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            userScore += 1
        } else {
            scoreTitle = "Wrong! That is the flag of \(countries[number])"
        }
        
        if questionCount < 7 {
            showingScore = true
        } else {
            showFinalScore = true
            showingScore = false
        }
        
        questionCount += 1
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    func resetGame() {
        userScore = 0
        questionCount = 0
        askQuestion()
        showFinalScore = false
    }
}

#Preview {
    ContentView()
}
