//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Benedict Neo on 1/18/24.
//

import SwiftUI

struct ContentView: View {
    
    let moves = ["🪨", "📄", "✂️"]

    @State private var compMove = Int.random(in: 0...2)
    @State private var shouldWin = Bool.random()
    @State private var questionCount = 0
    @State private var score = 0
    @State private var showFinalScore = false
    
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Text("剪刀石头布")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack {
                    Text("App move: \(moves[compMove])")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("You should \(shouldWin ? "win" : "lose")")
                        .font(.title)
                        .foregroundColor(shouldWin ? .green : .red)
                }
                .padding()
                .background(Color.gray.opacity(0.25))
                .cornerRadius(20)

                Spacer()
                
                HStack {
                    ForEach(moves, id: \.self) { move in
                        Button(action: {
                            withAnimation {
                                moveTapped(move)
                            }
                        }) {
                            Text(move)
                                .font(.system(size: 60))
                        }
                    }
                }

                Spacer()
                
                Text("Score: \(score)")
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
        }
        .alert("Game Over", isPresented: $showFinalScore) {
            Button("Restart", action: resetGame)
        } message: {
            Text("Your final score is \(score)")
        }
    }
    
    func moveTapped(_ move: String ) {
        let winningMoves = ["📄", "✂️", "🪨"]
        let losingMoves = ["✂️", "🪨", "📄"]
        
        if shouldWin {
            if winningMoves[compMove] == move {
                score += 1
            } else {
                score -= 1
            }
        }
        else {
            if losingMoves[compMove] == move {
                score += 1
            } else {
                score -= 1
            }
        }
        
        if questionCount == 4 {
            showFinalScore = true
        }
        
        questionCount += 1
        compMove = Int.random(in: 0...2)
        shouldWin.toggle()
    }
    
    func resetGame() {
        score = 0
        questionCount = 0
        showFinalScore = false
    }
}

#Preview {
    ContentView()
}
