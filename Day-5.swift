let input = "..."

let sections = input.split(separator: "\n\n")

class Map {
    struct Item: Comparable {
        static func < (lhs: Map.Item, rhs: Map.Item) -> Bool {
            lhs.sourceStart < rhs.sourceStart
        }

        let destinationStart: Int
        let sourceStart: Int
        let length: Int

        var sourceRange: ClosedRange<Int> {
            sourceStart...(sourceStart + length - 1)
        }

        var destinationRange: ClosedRange<Int> {
            destinationStart...(destinationStart + length - 1)
        }
    }

    var items: [Item]

    init(items: [Item]) {
        self.items = items
    }

    init(rawValue: String) {
        let lines = rawValue.split(separator: "\n")

        self.items = lines.map { line in
            let nums = line.split(separator: " ").compactMap { Int($0)! }

            return Item(
                destinationStart: nums[0],
                sourceStart: nums[1],
                length: nums[2]
            )
        }
        .sorted()
    }

    var reversed: Map {
        Map(
            items: items.map {
                Item(
                    destinationStart: $0.sourceStart,
                    sourceStart: $0.destinationStart,
                    length: $0.length
                )
            }
        )
    }

    func destination(for source: Int) -> Int {
        biDestination(for: source, lookupItems: items)
    }

    func biDestination(for source: Int, lookupItems: [Item]) -> Int {
        guard !lookupItems.isEmpty else {
            return source
        }

        let item = lookupItems[lookupItems.count / 2]

        if item.sourceRange ~= source {
            let idx = item.sourceRange.firstIndex(of: source)!
            let relativeDistance = item.sourceRange.distance(from: item.sourceRange.startIndex, to: idx)
            let destinationIdx = item.destinationRange.index(item.destinationRange.startIndex, offsetBy: relativeDistance)

            return item.destinationRange[destinationIdx]
        } else if source <= item.sourceRange.lowerBound {
            return biDestination(for: source, lookupItems: Array(lookupItems.prefix(lookupItems.count / 2)))
        } else if source >= item.sourceRange.upperBound {
            return biDestination(for: source, lookupItems: Array(lookupItems.suffix(lookupItems.count / 2)))
        } else {
            fatalError()
        }
    }
}

let seeds = sections[0].split(separator: ": ")[1].split(separator: " ").map { Int($0)! }

func rawSection(with id: String) -> String {
    String(
        sections
            .first(where: { $0.hasPrefix(id) })!
            .dropFirst("\(id) map:\n".count)
    )
}

let maps = [
    Map(rawValue: rawSection(with: "seed-to-soil")),
    Map(rawValue: rawSection(with: "soil-to-fertilizer")),
    Map(rawValue: rawSection(with: "fertilizer-to-water")),
    Map(rawValue: rawSection(with: "water-to-light")),
    Map(rawValue: rawSection(with: "light-to-temperature")),
    Map(rawValue: rawSection(with: "temperature-to-humidity")),
    Map(rawValue: rawSection(with: "humidity-to-location"))
]

func location(for seed: Int) -> Int {
    maps.reduce(seed, { partialResult, map in
        map.destination(for: partialResult)
    })
}

// Task 1
do {
    print(seeds.map(location(for:)).min()!)
}

// Task 2
do {
    var seedsRanges = [ClosedRange<Int>]()

    for i in 1..<seeds.count {
        if !i.isMultiple(of: 2) {
            seedsRanges.append(seeds[i-1]...(seeds[i-1] + seeds[i] - 1))
        }
    }

    var minResult = Int.max

    for range in seedsRanges {
        for seed in range {
            minResult = min(minResult, location(for: seed))
        }
    }

    print(minResult)
}
