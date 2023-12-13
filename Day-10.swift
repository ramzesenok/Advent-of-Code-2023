let input = "..."

struct IndexPair: Equatable {
    let x: Int
    let y: Int
}

enum Tile: String {
    case vertical = "|"
    case horizontal = "-"
    case northEast = "L"
    case northWest = "J"
    case southWest = "7"
    case southEast = "F"
    case ground = "."
    case start = "S"

    var advancingPossibilities: [Direction] {
        switch self {
        case .vertical: [.north, .south]
        case .horizontal: [.east, .west]
        case .northEast: [.north, .east]
        case .northWest: [.north, .west]
        case .southWest: [.south, .west]
        case .southEast: [.south, .east]
        case .ground: Direction.allCases
        case .start: Direction.allCases
        }
    }
}

enum Direction: CaseIterable {
    case north, east, south, west

    var counterpart: Direction {
        switch self {
        case .north: .south
        case .east: .west
        case .south: .north
        case .west: .east
        }
    }

    var advancingPossibilities: [Tile] {
        switch self {
        case .north: [.vertical, .southEast, .southWest, .start]
        case .east: [.horizontal, .northWest, .southWest, .start]
        case .south: [.vertical, .northEast, .northWest, .start]
        case .west: [.horizontal, .northEast, .southEast, .start]
        }
    }

    func newIndices(indices: IndexPair) -> IndexPair {
        switch self {
        case .north: IndexPair(x: indices.x, y: indices.y-1)
        case .east: IndexPair(x: indices.x+1, y: indices.y)
        case .south: IndexPair(x: indices.x, y: indices.y+1)
        case .west: IndexPair(x: indices.x-1, y: indices.y)
        }
    }
}

let lines = input.split(separator: "\n")

var inputMatrix = Array(repeating: Array(repeating: Tile.ground, count: lines.count), count: lines[0].count)

for idx in 0..<lines[0].count {
    for lineIdx in 0..<lines.count {
        inputMatrix[idx][lineIdx] = Tile(rawValue: String(Array(lines[lineIdx])[idx]))!
    }
}

func findNextDirection(for indices: IndexPair, in matrix: [[Tile]], cameFrom: Direction? = nil) -> Direction? {
    let currentTile = matrix[indices.x][indices.y]

    for direction in currentTile.advancingPossibilities.filter({ $0 != cameFrom }) {
        let newIndices = direction.newIndices(indices: indices)

        if 0..<matrix.count ~= newIndices.x && 0..<matrix[0].count ~= newIndices.y {
            let newTile = matrix[newIndices.x][newIndices.y]

            if direction.advancingPossibilities.contains(newTile) {
                return direction
            }
        }
    }

    return nil
}

var x = inputMatrix.firstIndex(where: { $0.contains(.start) })!
var y = inputMatrix[x].firstIndex(of: .start)!

let startIndices = IndexPair(x: x, y: y)

func getLoop(matrix: [[Tile]], start indices: IndexPair) -> (loop: [Tile], indices: [IndexPair])? {
    var loop = [Tile]()
    var passedIndices = [IndexPair]()

    var currentTileDirection: Direction?
    var currentTileIndices = indices

    if matrix[indices.x][indices.y] == .start {
        if let startDirection = findNextDirection(for: indices, in: matrix) {
            currentTileDirection = startDirection
            currentTileIndices = startDirection.newIndices(indices: indices)

            loop.append(.start)
        } else {
            return nil
        }
    }

    loop.append(matrix[currentTileIndices.x][currentTileIndices.y])
    passedIndices.append(currentTileIndices)

    while true {
        let newDirection = findNextDirection(
            for: currentTileIndices,
            in: matrix,
            cameFrom: currentTileDirection?.counterpart
        )

        if let newDirection {
            let newIndices = newDirection.newIndices(indices: currentTileIndices)

            if passedIndices.first == newIndices {
                return (loop, passedIndices)
            }

            currentTileDirection = newDirection
            currentTileIndices = newIndices

            passedIndices.append(newIndices)
        } else {
            return nil
        }

        loop.append(matrix[currentTileIndices.x][currentTileIndices.y])
    }
}

func tileToReplaceStartWith(in matrix: [[Tile]], at indices: IndexPair) -> Tile {
    let top = matrix[x][y-1]
    let right = matrix[x+1][y]
    let bottom = matrix[x][y+1]
    let left = matrix[x-1][y]

    let topConnects = [.vertical, .southWest, .southEast].contains(top)
    let rightConnects = [.horizontal, .northWest, .southWest].contains(right)
    let bottomConnects = [.vertical, .northWest, .northEast].contains(bottom)
    let leftConnects = [.horizontal, .northEast, .southEast].contains(left)

    if topConnects {
        if rightConnects {
            return .northEast
        }

        if bottomConnects {
            return .vertical
        }

        if leftConnects {
            return .northWest
        }
    }

    if rightConnects {
        if bottomConnects {
            return .southEast
        }

        if leftConnects {
            return .horizontal
        }
    }

    if bottomConnects {
        if leftConnects {
            return .southWest
        }
    }

    fatalError()
}

// Task 1
do {
    let count = getLoop(matrix: inputMatrix, start: startIndices)!.loop.count / 2
}

// Taks 2
do {
    var enclosedTiles = ([Tile](), [IndexPair]())

    let originalLoop = getLoop(matrix: inputMatrix, start: startIndices)!
    let startReplacement = tileToReplaceStartWith(in: inputMatrix, at: startIndices)
    var inputMatrixWithoutStart = inputMatrix
    inputMatrixWithoutStart[startIndices.x][startIndices.y] = startReplacement

    for x in 0..<inputMatrixWithoutStart.count {
        var didOpenWithEast = false
        var didOpenWithWest = false

        var isIn = false

        for y in 0..<inputMatrixWithoutStart[x].count {
            let tile = inputMatrixWithoutStart[x][y]
            let indices = IndexPair(x: x, y: y)
            let isPartOfOriginalLoop = originalLoop.indices.contains(indices)

            switch tile {
            case .vertical:
                if !isPartOfOriginalLoop && isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .horizontal:
                if isPartOfOriginalLoop {
                    isIn.toggle()
                } else if isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .northEast:
                if isPartOfOriginalLoop {
                    if didOpenWithWest {
                        isIn.toggle()
                    }

                    didOpenWithEast = false
                    didOpenWithWest = false
                } else if isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .northWest:
                if isPartOfOriginalLoop {
                    if didOpenWithEast {
                        isIn.toggle()
                    }

                    didOpenWithEast = false
                    didOpenWithWest = false
                } else if isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .southWest:
                if isPartOfOriginalLoop {
                    didOpenWithWest = true
                } else if isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .southEast:
                if isPartOfOriginalLoop {
                    didOpenWithEast = true
                } else if isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .ground:
                if isIn {
                    enclosedTiles.0.append(tile)
                    enclosedTiles.1.append(indices)
                }
            case .start:
                fatalError()
            }
        }
    }
}
