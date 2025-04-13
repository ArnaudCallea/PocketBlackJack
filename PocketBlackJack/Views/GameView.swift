import SwiftUI

struct GameView: View {
    @StateObject private var gameState = GameState()
    @State private var selectedPlayerCards: [Card] = []
    @State private var selectedDealerCard: Card?
    
    var body: some View {
        VStack(spacing: 20) {
            // Dealer's card
            VStack {
                Text("Dealer's Card")
                    .font(.headline)
                if let dealerCard = selectedDealerCard {
                    CardView(card: dealerCard)
                } else {
                    Text("Select dealer's card")
                        .foregroundColor(.gray)
                }
            }
            
            // Player's cards
            VStack {
                Text("Your Cards")
                    .font(.headline)
                HStack {
                    ForEach(selectedPlayerCards) { card in
                        CardView(card: card)
                    }
                    if selectedPlayerCards.count < 2 {
                        Text("Select your cards")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Card selection
            CardSelectionView(
                selectedPlayerCards: $selectedPlayerCards,
                selectedDealerCard: $selectedDealerCard,
                maxPlayerCards: 2
            )
            
            // Probabilities
            if let probabilities = gameState.probabilities {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Probabilities")
                        .font(.headline)
                    
                    ProbabilityRow(title: "Hit - Bust:", value: probabilities.hitBust)
                    ProbabilityRow(title: "Hit - Win:", value: probabilities.hitWin)
                    ProbabilityRow(title: "Hit - Blackjack:", value: probabilities.hitBlackjack)
                    ProbabilityRow(title: "Stand - Win:", value: probabilities.standWin)
                    ProbabilityRow(title: "Stand - Lose:", value: probabilities.standLose)
                    
                    if probabilities.splitWin > 0 {
                        ProbabilityRow(title: "Split - Win:", value: probabilities.splitWin)
                        ProbabilityRow(title: "Split - Bust:", value: probabilities.splitBust)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .onChange(of: selectedPlayerCards) { _ in
            gameState.playerCards = selectedPlayerCards
            gameState.calculateProbabilities()
        }
        .onChange(of: selectedDealerCard) { _ in
            gameState.dealerCard = selectedDealerCard
            gameState.calculateProbabilities()
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        Text(card.displayName)
            .font(.system(size: 24))
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}

struct CardSelectionView: View {
    @Binding var selectedPlayerCards: [Card]
    @Binding var selectedDealerCard: Card?
    let maxPlayerCards: Int
    
    var body: some View {
        VStack {
            Text("Select Cards")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Suit.allCases, id: \.self) { suit in
                        ForEach(Rank.allCases, id: \.self) { rank in
                            let card = Card(suit: suit, rank: rank)
                            Button(action: {
                                selectCard(card)
                            }) {
                                CardView(card: card)
                                    .opacity(isCardSelected(card) ? 0.5 : 1.0)
                            }
                            .disabled(isCardSelected(card))
                        }
                    }
                }
            }
        }
    }
    
    private func selectCard(_ card: Card) {
        if selectedDealerCard == nil {
            selectedDealerCard = card
        } else if selectedPlayerCards.count < maxPlayerCards {
            selectedPlayerCards.append(card)
        }
    }
    
    private func isCardSelected(_ card: Card) -> Bool {
        return selectedPlayerCards.contains(where: { $0.id == card.id }) || selectedDealerCard?.id == card.id
    }
}

struct ProbabilityRow: View {
    let title: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(Int(value * 100))%")
                .bold()
        }
    }
}

#Preview {
    GameView()
} 