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
                VStack(alignment: .leading, spacing: 15) {
                    Text("Action Probabilities")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    // Hit probabilities
                    VStack(alignment: .leading, spacing: 5) {
                        Text("HIT")
                            .font(.subheadline)
                            .bold()
                        ProbabilityBar(title: "Win:", value: probabilities.hitWin, color: .green)
                        ProbabilityBar(title: "Bust:", value: probabilities.hitBust, color: .red)
                        if probabilities.hitBlackjack > 0 {
                            ProbabilityBar(title: "Blackjack:", value: probabilities.hitBlackjack, color: .blue)
                        }
                    }
                    
                    // Stand probabilities
                    VStack(alignment: .leading, spacing: 5) {
                        Text("STAND")
                            .font(.subheadline)
                            .bold()
                        ProbabilityBar(title: "Win:", value: probabilities.standWin, color: .green)
                        ProbabilityBar(title: "Lose:", value: probabilities.standLose, color: .red)
                    }
                    
                    // Split probabilities (if applicable)
                    if probabilities.splitWin > 0 {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("SPLIT")
                                .font(.subheadline)
                                .bold()
                            ProbabilityBar(title: "Win:", value: probabilities.splitWin, color: .green)
                            ProbabilityBar(title: "Bust:", value: probabilities.splitBust, color: .red)
                        }
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
            .frame(width: 40, height: 60)
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
                    ForEach(Rank.allCases, id: \.self) { rank in
                        let card = Card(rank: rank)
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

struct ProbabilityBar: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value * 100))%")
                    .bold()
            }
            GeometryReader { geometry in
                Rectangle()
                    .fill(color.opacity(0.3))
                    .frame(width: geometry.size.width * CGFloat(value))
                    .frame(height: 8)
                    .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    GameView()
} 