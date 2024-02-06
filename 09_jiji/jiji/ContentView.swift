//
//  ContentView.swift
//  jiji
//
//  Created by Benedict Neo on 2/5/24.
//

import SwiftUI
import OpenAI
import Combine

struct QuizResponse: Codable {
    let questions: [QuizItem]
}

struct QuizItem: Codable, Identifiable, Equatable {
    var id: Int
    let question: String
    let isTrue: Bool
    let explanation: String
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


final class QuizGeneratorViewModel: ObservableObject {
    @Published var quizItems: [QuizItem] = []
    @Published var isGenerating = false
    
    private var cancellables: Set<AnyCancellable> = []
    private var openAI = OpenAI(apiToken: "YOUR_API_TOKEN")
    
    func generateQuizContent(forTopic topic: String) {
        isGenerating = true
        
        let actualTopic = topic.lowercased() == "random" ? "a random topic" : topic
        let prompt = """
        Generate five scientifically accurate and thought-provoking questions about '\(actualTopic)' without using the phrases "is it true" or "true or false" in the questions. The format should be indirect, requiring a true or false answer but formulated in a more engaging and educational manner. Each question should:
        1. Challenge a common misconception or explore a less well-known fact, indirectly prompting for a true or false answer.
        2. Be crafted to provoke curiosity, encourage learning, and engage the audience without directly revealing the question format.
        3. Avoid being overly obvious, simplistic, or misleading, ensuring they surprise or enlighten someone familiar with the topic.
        
        After each question, include an explanation providing insight or additional context, without starting with "This statement is true/false."
        
        Format the output as JSON:
        
        {
          "questions": [
            {
              "id": 1,
              "question": "a question reflecting a common misconception or a fact about \(actualTopic)",
              "isTrue": false, // or true, based on factual accuracy
              "explanation": "a brief, informative explanation, no longer than two sentences, related to the question, offering context or debunking misconceptions."
            },
            // Repeat for each question, ensuring a diverse range of topics within \(actualTopic) are covered.
          ]
        }
        
        Craft each question and explanation using credible scientific sources or principles to ensure accuracy and educational value. The goal is to create a set of engaging questions that inform and challenge the audience, enhancing their understanding of \(actualTopic).
        
        """
        
        let query = ChatQuery(model: "gpt-3.5-turbo-0125",
                              messages: [Chat(role: .user, content: prompt)],
                              temperature: 0.3,
                              n: 1,
                              stop: ["\"}"],
                              maxTokens: 1024)
        
        
        openAI.chats(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                DispatchQueue.main.async {
                    self?.isGenerating = false
                }
                if case .failure(let error) = completion {
                    print("JSON parsing error: \(error)")
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] chatResult in
                self?.parseResult(chatResult)
            })
            .store(in: &cancellables)
    }
    
    private func parseResult(_ result: ChatResult) {
        guard let jsonStr = result.choices.first?.message.content else { return }
        
        print(jsonStr)
        
        do {
            let data = Data(jsonStr.utf8)
            let response = try JSONDecoder().decode(QuizResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.quizItems = response.questions
            }
        } catch {
            print("JSON parsing error: \(error)")
        }
    }
}

final class QuizAnsweringViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var userAnswers: [Bool] = []
    @Published var isQuizCompleted = false
    @Published var score = 0
    @Published var quizItems: [QuizItem] = []
    
    
    var currentQuestion: QuizItem? {
        guard currentQuestionIndex < quizItems.count else {return nil}
        return quizItems[safe: currentQuestionIndex]
    }
    
    func answerQuestion(with answer: Bool) {
        if let correctAnswer = quizItems[safe: currentQuestionIndex]?.isTrue {
            if correctAnswer == answer {
                score += 1
            }
        }
        
        userAnswers.append(answer)
        
        if currentQuestionIndex < quizItems.count - 1 {
            currentQuestionIndex += 1
        } else {
            isQuizCompleted = true
        }
    }
    
    var progress: Double {
        guard quizItems.count > 0 else { return 0}
        let progress =  Double(currentQuestionIndex + 1) / Double(quizItems.count)
        return min(max(progress, 0), 1)
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 4)
                    .opacity(0.3)
                    .foregroundColor(Color(white: 0.2))
                
                Rectangle()
                    .frame(width: max(CGFloat(self.progress) * geometry.size.width, 0), height: 4)
                    .foregroundColor(Color.white.opacity(0.85))
                    .animation(.linear, value: progress)
            }
        }
        .frame(height: 4)
    }
}


struct QuizAnsweringView: View {
    @ObservedObject var answeringViewModel: QuizAnsweringViewModel
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if let question = answeringViewModel.currentQuestion {
                    Text(question.question)
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    Spacer(minLength: 20)
                }
                
                HStack(spacing: 30) {
                    Button(action: { answeringViewModel.answerQuestion(with: true)}) {
                        Text("true")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    
                    Button(action: { answeringViewModel.answerQuestion(with: false)}) {
                        Text("false")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                }
                .padding(.bottom, 70)
                
                ProgressBar(progress: answeringViewModel.progress)
                    .frame(height: 10)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
}

struct QuestionResultRow: View {
    var item: QuizItem
    var userAnswer: Bool
    @Binding var showExplanation: Bool
    
    var body: some View {
        HStack {
            Image(systemName: userAnswer == item.isTrue ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(userAnswer == item.isTrue ? .green : .red)
                .alignmentGuide(VerticalAlignment.firstTextBaseline) { context in
                    context[VerticalAlignment.firstTextBaseline]
                }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(item.question)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                if showExplanation {
                    Text(item.explanation)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                showExplanation.toggle()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}


struct QuizResultsView: View {
    @ObservedObject var viewModel: QuizAnsweringViewModel
    let restartQuiz: () -> Void
    let startNewQuiz: () -> Void
    @State private var showExplanation: [Bool]
    
    init(viewModel: QuizAnsweringViewModel, restartQuiz: @escaping () -> Void, startNewQuiz: @escaping () -> Void) {
        self.viewModel = viewModel
        self.restartQuiz = restartQuiz
        self.startNewQuiz = startNewQuiz
        _showExplanation = State(initialValue: Array(repeating: false, count: viewModel.quizItems.count))
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Your Score: \(viewModel.score)/\(viewModel.quizItems.count)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.vertical, 50)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(zip(viewModel.quizItems.indices, viewModel.quizItems)), id: \.0) { index, item in
                            QuestionResultRow(
                                item: item,
                                userAnswer: viewModel.userAnswers[safe: index] ?? false,
                                showExplanation: $showExplanation[index]
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 500)
                
                Spacer()
                
                
                HStack(spacing: 50) {
                    Button("Same topic") {
                        restartQuiz()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Button("New topic") {
                        startNewQuiz()
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}



struct PlainTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(0.75), lineWidth: 1)
            )
    }
}


struct ContentView: View {
    
    @StateObject private var generatorViewModel = QuizGeneratorViewModel()
    @StateObject private var answeringViewModel = QuizAnsweringViewModel()
    @State private var topic: String = ""
    @State private var isQuizActive = false
    @State private var showQuizResults = false
    
    private func resetQuizState() {
        answeringViewModel.currentQuestionIndex = 0
        answeringViewModel.userAnswers = []
        answeringViewModel.isQuizCompleted = false
        answeringViewModel.score = 0
    }
    
    private func generateQuiz(forTopic topic: String) {
        let topicToUse = topic.isEmpty ? "random" : topic
        generatorViewModel.generateQuizContent(forTopic: topicToUse)
        resetQuizState()
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("jiji")
                        .font(.largeTitle)
                        .fontDesign(.serif)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    
                    if generatorViewModel.isGenerating {
                        ProgressView("generating...")
                            .scaleEffect(1.2)
                            .foregroundColor(Color(white: 0.7))

                    } else if isQuizActive {
                        QuizAnsweringView(answeringViewModel: answeringViewModel)
                            .onChange(of: answeringViewModel.isQuizCompleted) {
                                showQuizResults = answeringViewModel.isQuizCompleted
                            }
                    }
                    else {
                        TextField("", text: $topic, prompt: Text("Enter a topic or leave blank...")
                            .foregroundColor(.gray))
                        .textFieldStyle(PlainTextFieldStyle())
                        .frame(width: 300, height: 50)
                        .padding(.bottom, 40)
                        .disableAutocorrection(true)
                        
                        Button("Quiz Me") {
                            generateQuiz(forTopic: topic)
                            isQuizActive = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 7)
                    }
                    
                    Spacer()
                    
                    
                }
                .onChange(of: generatorViewModel.quizItems) {
                    answeringViewModel.quizItems = generatorViewModel.quizItems
                    if !generatorViewModel.quizItems.isEmpty {
                        isQuizActive = true
                        showQuizResults = false
                    }
                }
            }
            .navigationDestination(isPresented: $showQuizResults) {
                QuizResultsView(viewModel: answeringViewModel,
                                restartQuiz: {
                    showQuizResults = false
                    generateQuiz(forTopic: topic)
                },
                                startNewQuiz: {
                    topic = ""
                    resetQuizState()
                    isQuizActive = false
                    showQuizResults = false
                }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
