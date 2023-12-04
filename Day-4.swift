var input = "..."

var lines = input.split(separator: "\n")

struct Card {
    let id: Int
    let winningNumbers: [Int]
    let availableNumbers: [Int]
    
    var matchingNumbers: [Int] {
        winningNumbers.filter(availableNumbers.contains)
    }
    
    var points: Int {        
        var points = 0
        
        switch matchingNumbers.count {
        case 0: 
            break
        case 1:
            points = 1
        default:
            points = 1
            
            matchingNumbers.dropLast().forEach { _ in
                points *= 2
            }
        }
        
        return points
    }
}

let digits = "1234567890"

let cards = lines.map { line in
    let cardDetails = line.split(separator: ":")
    let id = Int(cardDetails[0].drop(while: { !digits.contains($0) }))!
    let numbers = cardDetails[1].split(separator: "|")
    
    let winningNumbers = numbers[0].split(separator: " ").compactMap { Int($0) }
    let availableNumbers = numbers[1].split(separator: " ").compactMap { Int($0) }
    
    return Card(
        id: id,
        winningNumbers: winningNumbers,
        availableNumbers: availableNumbers
    )
}

// Task 1
do {
   let sum = cards.map(\.points).reduce(0, +)
}

// Task 2
do {    
    var totalPointsCache = [Int: Int]()
    
    func getPoints(for card: Card) -> Int {
        if let result = totalPointsCache[card.id] {
            return result
        }
        
        let matchCount = card.matchingNumbers.count
        
        if matchCount > 0 {
            let nextCards = (1...matchCount).map { id in
                cards.first(where: { $0.id == (card.id + id) })!
            }
            
            totalPointsCache[card.id] = 1 + nextCards.map(getPoints).reduce(0, +)
        } else {
            totalPointsCache[card.id] = 1
        }
        
        return totalPointsCache[card.id]!
    }
    
    let sum = cards.map(getPoints).reduce(0, +)
}
