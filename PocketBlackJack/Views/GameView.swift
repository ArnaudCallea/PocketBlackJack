import SwiftUI

struct GameView: View {
    @StateObject private var gameState = GameState()
    @State private var selectedPlayerCards: [Card] = []
    @State private var selectedDealerCard: Card?
    @State private var showProbabilities = false
    
    private let ranks = Rank.allCases
    private let cardsPerRow = 4
    private let numberOfRows = 3
    
    var body: some View {
        VStack(spacing: 20) {
            // Dealer's card
            VStack {
                Text("Dealer's Card")
                    .font(.headline)
                if let dealerCard = selectedDealerCard {
                    CardView(card: dealerCard)
                        .frame(width: 100, height: 150)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 150)
                        .overlay(
                            Text("Select Dealer Card")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Player's cards
            VStack {
                Text("Player's Cards")
                    .font(.headline)
                HStack(spacing: 10) {
                    ForEach(selectedPlayerCards) { card in
                        CardView(card: card)
                            .frame(width: 100, height: 150)
                    }
                    if selectedPlayerCards.count < 2 {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 150)
                            .overlay(
                                Text("Select Card")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            )
                    }
                }
            }
            
            // Card selection grid
            VStack(spacing: 10) {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<cardsPerRow, id: \.self) { col in
                            let index = row * cardsPerRow + col
                            if index < ranks.count {
                                let rank = ranks[index]
                                let card = Card(rank: rank)
                                CardView(card: card)
                                    .frame(width: 60, height: 90)
                                    .onTapGesture {
                                        if selectedPlayerCards.count < 2 {
                                            selectedPlayerCards.append(card)
                                            if selectedPlayerCards.count == 2 && selectedDealerCard != nil {
                                                gameState.playerCards = selectedPlayerCards
                                                gameState.dealerCard = selectedDealerCard
                                                gameState.calculateProbabilities()
                                                showProbabilities = true
                                            }
                                        } else if selectedDealerCard == nil {
                                            selectedDealerCard = card
                                            if selectedPlayerCards.count == 2 {
                                                gameState.playerCards = selectedPlayerCards
                                                gameState.dealerCard = selectedDealerCard
                                                gameState.calculateProbabilities()
                                                showProbabilities = true
                                            }
                                        }
                                    }
                                    .opacity(canSelectCard(card) ? 1.0 : 0.3)
                            }
                        }
                    }
                }
            }
            .padding()
            
            // Best move recommendation
            if showProbabilities, let probabilities = gameState.probabilities {
                VStack(spacing: 10) {
                    Text("Best Move")
                        .font(.title2)
                        .bold()
                    
                    let bestMove = calculateBestMove(probabilities)
                    Text(bestMove)
                        .font(.title3)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
            }
            
            // Reset button
            Button(action: resetGame) {
                Text("Reset Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func canSelectCard(_ card: Card) -> Bool {
        if selectedPlayerCards.count < 2 {
            return !selectedPlayerCards.contains(where: { $0.id == card.id })
        } else if selectedDealerCard == nil {
            return !selectedPlayerCards.contains(where: { $0.id == card.id })
        }
        return false
    }
    
    private func calculateBestMove(_ probabilities: GameState.Probabilities) -> String {
        let hitSuccess = probabilities.hitWin + probabilities.hitBlackjack
        let standSuccess = probabilities.standWin
        
        if selectedPlayerCards[0].rank == selectedPlayerCards[1].rank {
            let splitSuccess = probabilities.splitWin
            if splitSuccess > hitSuccess && splitSuccess > standSuccess {
                return "SPLIT"
            }
        }
        
        if hitSuccess > standSuccess {
            return "HIT"
        } else {
            return "STAND"
        }
    }
    
    private func resetGame() {
        selectedPlayerCards = []
        selectedDealerCard = nil
        gameState.playerCards = []
        gameState.dealerCard = nil
        gameState.probabilities = nil
        showProbabilities = false
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .overlay(
                VStack {
                    Text(card.rank.description)
                        .font(.system(size: 30))
                    Text("\(card.rank.value)")
                        .font(.caption)
                }
            )
            .shadow(radius: 2)
    }
}

#Preview {
    GameView()
} 