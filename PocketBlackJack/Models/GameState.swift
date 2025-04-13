import Foundation

class GameState: ObservableObject {
    @Published var playerCards: [Card] = []
    @Published var dealerCard: Card?
    @Published var probabilities: Probabilities?
    
    struct Probabilities {
        let hitBust: Double
        let hitWin: Double
        let hitBlackjack: Double
        let standWin: Double
        let standLose: Double
        let splitWin: Double
        let splitBust: Double
    }
    
    func calculateProbabilities() {
        guard let dealerCard = dealerCard,
              playerCards.count == 2 else { return }
        
        let playerTotal = calculateHandValue(playerCards)
        let dealerUpCard = dealerCard.rank.value
        
        // Calculate probabilities based on basic strategy and card counting
        // These are simplified calculations - in reality, this would be more complex
        let remainingCards = calculateRemainingCards()
        
        // Calculate hit probabilities
        let hitBust = calculateHitBustProbability(playerTotal: playerTotal, remainingCards: remainingCards)
        let hitWin = calculateHitWinProbability(playerTotal: playerTotal, dealerUpCard: dealerUpCard, remainingCards: remainingCards)
        let hitBlackjack = calculateHitBlackjackProbability(playerTotal: playerTotal, remainingCards: remainingCards)
        
        // Calculate stand probabilities
        let standWin = calculateStandWinProbability(playerTotal: playerTotal, dealerUpCard: dealerUpCard, remainingCards: remainingCards)
        let standLose = calculateStandLoseProbability(playerTotal: playerTotal, dealerUpCard: dealerUpCard, remainingCards: remainingCards)
        
        // Calculate split probabilities (if applicable)
        let canSplit = playerCards[0].rank == playerCards[1].rank
        let splitWin = canSplit ? calculateSplitWinProbability(playerCards: playerCards, dealerUpCard: dealerUpCard, remainingCards: remainingCards) : 0
        let splitBust = canSplit ? calculateSplitBustProbability(playerCards: playerCards, remainingCards: remainingCards) : 0
        
        probabilities = Probabilities(
            hitBust: hitBust,
            hitWin: hitWin,
            hitBlackjack: hitBlackjack,
            standWin: standWin,
            standLose: standLose,
            splitWin: splitWin,
            splitBust: splitBust
        )
    }
    
    private func calculateHandValue(_ cards: [Card]) -> Int {
        var total = 0
        var aces = 0
        
        for card in cards {
            if card.rank == .ace {
                aces += 1
                total += 11
            } else {
                total += card.rank.value
            }
        }
        
        while total > 21 && aces > 0 {
            total -= 10
            aces -= 1
        }
        
        return total
    }
    
    private func calculateRemainingCards() -> [Card] {
        // This would be more complex in a real implementation
        // For now, we'll return a simplified version
        var remaining: [Card] = []
        for rank in Rank.allCases {
            let card = Card(rank: rank)
            if !playerCards.contains(where: { $0.id == card.id }) && dealerCard?.id != card.id {
                remaining.append(card)
            }
        }
        return remaining
    }
    
    // Simplified probability calculations
    private func calculateHitBustProbability(playerTotal: Int, remainingCards: [Card]) -> Double {
        let bustCards = remainingCards.filter { card in
            let newTotal = playerTotal + card.rank.value
            return newTotal > 21
        }
        return Double(bustCards.count) / Double(remainingCards.count)
    }
    
    private func calculateHitWinProbability(playerTotal: Int, dealerUpCard: Int, remainingCards: [Card]) -> Double {
        // Simplified calculation
        return 0.4 // Placeholder
    }
    
    private func calculateHitBlackjackProbability(playerTotal: Int, remainingCards: [Card]) -> Double {
        // Simplified calculation
        return 0.1 // Placeholder
    }
    
    private func calculateStandWinProbability(playerTotal: Int, dealerUpCard: Int, remainingCards: [Card]) -> Double {
        // Simplified calculation
        return 0.45 // Placeholder
    }
    
    private func calculateStandLoseProbability(playerTotal: Int, dealerUpCard: Int, remainingCards: [Card]) -> Double {
        // Simplified calculation
        return 0.55 // Placeholder
    }
    
    private func calculateSplitWinProbability(playerCards: [Card], dealerUpCard: Int, remainingCards: [Card]) -> Double {
        // Simplified calculation
        return 0.35 // Placeholder
    }
    
    private func calculateSplitBustProbability(playerCards: [Card], remainingCards: [Card]) -> Double {
        // Simplified calculation
        return 0.25 // Placeholder
    }
} 