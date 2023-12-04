let input = "..."

struct Game {
    struct Pull {
        let r: Int
        let g: Int
        let b: Int
    }
    
    let id: Int
    let pulls: [Pull]
}

let lines = input.split(separator: "\n")
let games = lines.map { line in
    let split = line.split(separator: ": ")
    let gameId = Int(split[0].dropFirst(5))!
    let rawPulls = split[1].split(separator: "; ")
    let pulls = rawPulls.map { rawPull in
        var r = 0
        var g = 0
        var b = 0
        
        let rawColors = rawPull.split(separator: ", ")
        
        rawColors.forEach { rawColor in
            let amount = Int(rawColor.prefix(while: { $0 != " " }))!
            
            if rawColor.hasSuffix("red") {
                r = amount
            } else if rawColor.hasSuffix("green") {
                g = amount
            } else if rawColor.hasSuffix("blue") {
                b = amount
            }
        }
        
        return Game.Pull(r: r, g: g, b: b)
    }
    
    return Game(id: gameId, pulls: pulls)
}

// Task 1
do {
    let filteredGames = games.filter { game in
        game.pulls.allSatisfy { pull in
            pull.r <= 12 && pull.g <= 13 && pull.b <= 14
        }
    }

    let idSum = filteredGames.map(\.id).reduce(0, +)
}

// Task 2
do {
    var powersSum = 0

    games.forEach { game in
        var minR = 0
        var minG = 0
        var minB = 0
        
        game.pulls.forEach { pull in
            minR = max(minR, pull.r)
            minG = max(minG, pull.g)
            minB = max(minB, pull.b)
        }

        powersSum += minR * minG * minB
    }
}