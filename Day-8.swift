let input = "..."

func lcm(_ a: Int, _ b: Int) -> Int {
    abs(a * b) / gcd(a, b)
}

func gcd(_ a: Int, _ b: Int) -> Int {
    var (a, b) = (a, b)

    while b != 0 {
        (a, b) = (b, a % b)
    }

    return a
}

enum Direction: String {
    case left = "L"
    case right = "R"
}

let split = input.split(separator: "\n\n")

let tilesRaw = split[1]
let directions = split[0].compactMap { Direction(rawValue: String($0)) }

var dict = [String: String]()

let lines = tilesRaw.split(separator: "\n")

for line in lines {
    let search = /([A-Z0-9]{3}) = \(([A-Z0-9]{3}), ([A-Z0-9]{3})\)/
    let (_, name, left, right) = try! search.wholeMatch(in: String(line))!.output

    dict[name + "L"] = String(left)
    dict[name + "R"] = String(right)
}

let tiles = lines.map { String($0.split(separator: " = ")[0]) }

// Task 1
do {
    var count = 0
    var currentTile = tiles.first(where: { $0 == "AAA" })!

    while true {
        let direction = directions[count % directions.count]

        let newTile: String = {
            switch direction {
            case .left: dict[currentTile + "L"]!
            case .right: dict[currentTile + "R"]!
            }
        }()

        if newTile == "ZZZ" {
            break
        } else {
            currentTile = newTile
        }

        count += 1
    }
}

// Task 2
do {
    let startTiles = Array(tiles.filter { $0.hasSuffix("A") })
    var stepsTillEnd = Array(repeating: 0, count: startTiles.count)

    for i in 0..<startTiles.count {
        var tile = startTiles[i]

        while !tile.hasSuffix("Z") {
            let direction = directions[stepsTillEnd[i] % directions.count]

            stepsTillEnd[i] += 1

            switch direction {
            case .left: tile = dict[tile + "L"]!
            case .right: tile = dict[tile + "R"]!
            }
        }
    }

    let result = stepsTillEnd.reduce(stepsTillEnd[0], lcm)
}
