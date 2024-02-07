//
//  ContentView.swift
//  10_iExpense
//
//  Created by Benedict Neo on 2/7/24.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems
            ) {
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}


extension Text {
    func style(for amount: Double) -> some View {
        self.foregroundColor(amount < 10 ? .green : amount < 100 ? .orange : .red)
            .fontWeight(.bold)
    }
}


struct SectionView: View {
    let section: String
    let items: [ExpenseItem]
    let removeItems: (IndexSet, String) -> Void
    
    var body: some View {
        if !items.isEmpty {
            Section(header: Text(section).foregroundColor(.gray)) {
                ForEach(items, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name).font(.headline).foregroundColor(.white)
                        }
                        Spacer()
                        Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .style(for: item.amount)
                    }
                }
                .onDelete { offsets in
                    removeItems(offsets, section)
                }
            }
        }
    }
}


struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    @State private var sheetHeight: CGFloat = .zero

    
    private func items(for section: String) -> [ExpenseItem] {
        expenses.items.filter { $0.type == section}
    }
    
    var body: some View {
        NavigationStack {
            List {
                SectionView(section: "Personal", items: items(for: "Personal"), removeItems: removeItems)
                SectionView(section: "Business", items: items(for: "Business"), removeItems: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Label("Add Expense", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                VStack{
                    AddView(expenses: expenses)
                }.presentationDetents([.height(300)])
            }
        }
        .colorScheme(.dark)
    }

    func removeItems(at offsets: IndexSet, from section: String) {
        let itemsInSection = items(for: section)
        var globalDeleteIndexSet = IndexSet()

        for offset in offsets {
            let id = itemsInSection[offset].id
            if let globalIndex = expenses.items.firstIndex(where: { $0.id == id }) {
                globalDeleteIndexSet.insert(globalIndex)
            }
        }

        expenses.items.remove(atOffsets: globalDeleteIndexSet)
    }

}

#Preview {
    ContentView()
}
