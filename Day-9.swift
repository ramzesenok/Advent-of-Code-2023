let input = "..."

let records = input.split(separator: "\n").map { line in line.split(separator: " ").map { Int($0)! } }

func findNextSequence(from sequence: [Int]) -> [Int] {
    var result = [Int]()

    for idx in 0..<(sequence.count - 1) {
        result.append(sequence[idx + 1] - sequence[idx])
    }

    return result
}

func findSolution(for record: [Int]) -> Int {
    var steps = [record]

    while !steps.last!.allSatisfy({ $0 == 0 }) {
        steps.append(findNextSequence(from: steps.last!))
    }

    steps[steps.count - 1].append(0)

    for idx in 1..<steps.count {
        steps[steps.count - idx - 1].append(steps[steps.count - idx - 1].last! + steps[steps.count - idx].last!)
    }

    return steps.first!.last!
}

// Task 1
do {
    let result = records.map(findSolution).reduce(0, +)
}

// Task 2
do {
    let result = records.map { findSolution(for: Array($0.reversed())) }.reduce(0, +)
}