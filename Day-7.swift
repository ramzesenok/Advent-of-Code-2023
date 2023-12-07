let input = "..."

let lines = input.split(separator: "\n")

enum CardType: String, CustomStringConvertible {
    case A, K, Q, J, T
    case nine = "9"
    case eight = "8"
    case seven = "7"
    case six = "6"
    case five = "5"
    case four = "4"
    case three = "3"
    case two = "2"

    func worth(usingJoker: Bool) -> Int {
        switch self {
        case .A: 14
        case .K: 13
        case .Q: 12
        case .J: usingJoker ? 1 : 11
        case .T: 10
        case .nine: 9
        case .eight: 8
        case .seven: 7
        case .six: 6
        case .five: 5
        case .four: 4
        case .three: 3
        case .two: 2
        }
    }

    var description: String {
        self.rawValue
    }
}

struct Hand {
    enum HandType: Int, Comparable {
        case highCard
        case pair
        case twoPairs
        case threeOfKind
        case fullHouse
        case fourOfKind
        case fiveOfKind

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    let set: [CardType]
    let bid: Int

    init(set: String, bid: Int) {
        self.set = set.compactMap { CardType.init(rawValue: String($0)) }
        self.bid = bid
    }

    func handType(usingJoker: Bool) -> HandType {
        if usingJoker {
            let restHand = set.filter({ $0 != .J })

            switch restHand.count {
            case 0, 1:
                return .fiveOfKind
            case 2:
                switch restHand.uniqueElementsCount {
                case 1: return .fiveOfKind
                case 2: return .fourOfKind
                default: fatalError()
                }
            case 3:
                switch restHand.uniqueElementsCount {
                case 1: return .fiveOfKind
                case 2: return .fourOfKind
                case 3: return .threeOfKind
                default: fatalError()
                }
            case 4:
                switch restHand.uniqueElementsCount {
                case 1:
                    return .fiveOfKind
                case 2:
                    switch restHand.filter({ $0 == restHand.first }).count {
                    case 1, 3: return .fourOfKind
                    case 2: return .fullHouse
                    default: fatalError()
                    }
                case 3:
                    return .threeOfKind
                case 4:
                    return .pair
                default:
                    fatalError()
                }
            case 5:
                return noJokerLookup
            default:
                fatalError()
            }
        } else {
            return noJokerLookup
        }
    }

    private var noJokerLookup: HandType {
        for i in 0..<set.count {
            let char = set[set.index(set.startIndex, offsetBy: i)]
            let invertedFilter = set.dropFirst(i).filter({ $0 != char })

            switch set.filter({ $0 == char }).count {
            case 5:
                return .fiveOfKind
            case 4:
                return .fourOfKind
            case 3:
                if invertedFilter.count == 2 && invertedFilter.uniqueElementsCount == 1 {
                    return .fullHouse
                } else {
                    return .threeOfKind
                }
            case 2:
                let invertedArr = Array(invertedFilter)

                if invertedFilter.count == 3 {
                    if invertedFilter.uniqueElementsCount == 1 {
                        return .fullHouse
                    } else if invertedArr.uniqueElementsCount == 2 {
                        return .twoPairs
                    }
                } else if invertedFilter.count == 2 && invertedArr.uniqueElementsCount == 1 {
                    return .twoPairs
                }

                return .pair
            case 1:
                break
            default:
                fatalError()
            }
        }

        return .highCard
    }
}

func isWorthLess(lhs: Hand, rhs: Hand, usingJoker: Bool) -> Bool {
    if lhs.handType(usingJoker: usingJoker) == rhs.handType(usingJoker: usingJoker) {
        for i in 0..<lhs.set.count {
            if lhs.set[i] == rhs.set[i] {
                continue
            }

            return lhs.set[i].worth(usingJoker: usingJoker) < rhs.set[i].worth(usingJoker: usingJoker)
        }
    }

    return lhs.handType(usingJoker: usingJoker) < rhs.handType(usingJoker: usingJoker)
}

extension Array where Element: Hashable {
    var uniqueElementsCount: Int {
        Set(self).count
    }
}

let hands = lines.map { line in
    let split = line.split(separator: " ")

    return Hand(
        set: String(split[0]),
        bid: Int(split[1])!
    )
}

func countBidSum(usingJoker: Bool) -> Int {
    hands
        .sorted(by: { isWorthLess(lhs: $0, rhs: $1, usingJoker: usingJoker) })
        .enumerated()
        .reduce(0, { partialResult, model in
            partialResult + (model.0 + 1) * model.1.bid
        })
}

// Task 1
do {
    countBidSum(usingJoker: false)
}

// Task 2
do {
    countBidSum(usingJoker: true)
}
