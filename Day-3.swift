var input = "..."

var lines = input.split(separator: "\n")

lines.insert(Substring(repeating: ".", count: lines[0].count), at: 0)
lines.append(Substring(repeating: ".", count: lines[0].count))

lines = lines.map {
    "." + $0 + ".." // 1 "." on both sides to allow idx +/- 1 and 1 additional "." in the end cause algorithm adds the number up only when it encounters the "." after the number (which should also be the case for the numbers in the very end of the line)
}

let digits = "0123456789"

struct AroundMatrix {
    enum NumberPosition {
        case topLeft, top, topRight, topLeftTop, topTopRight, allTop
        case left, right
        case bottomLeft, bottom, bottomRight, bottomLeftBottom, bottomBottomRight, allBottom
    }
    
    let (topLeft, top, topRight): (Character, Character, Character)
    let (left, right): (Character, Character)
    let (bottomLeft, bottom, bottomRight): (Character, Character, Character)
    
    var allTop: [Character] {
        [topLeft, top, topRight]
    }
    
    var allBottom: [Character] {
        [bottomLeft, bottom, bottomRight]
    }
    
    var all: [Character] {
        allTop + [left, right] + allBottom
    }
    
    var isAdjacentToSymbol: Bool {
        !all.allSatisfy((digits + ".").contains)
    }
    
    var numbersAroundPositions: [NumberPosition] {
        var result = [NumberPosition]()
        
        let filteredTop = allTop.filter(digits.contains)
        
        switch filteredTop.count {
        case 0:
            break
        case 1:
            if digits.contains(top) {
                result.append(.top)
            } else if digits.contains(topLeft) {
                result.append(.topLeft)
            } else if digits.contains(topRight) {
                result.append(.topRight)
            } else {
                fatalError()
            }
        case 2:
            if digits.contains(topLeft) && digits.contains(topRight) {
                result.append(.topLeft)
                result.append(.topRight)
            } else if digits.contains(topLeft) && digits.contains(top) {
                result.append(.topLeftTop)
            } else if digits.contains(top) && digits.contains(topRight) {
                result.append(.topTopRight)
            } else {
                fatalError()
            }
        case 3: 
            result.append(.allTop)
        default: 
            fatalError()
        }
        
        if digits.contains(left) {
            result.append(.left)
        }
        
        if digits.contains(right) {
            result.append(.right)
        }
        
        let filteredBottom = allBottom.filter(digits.contains)
        
        switch filteredBottom.count {
        case 0:
            break
        case 1:
            if digits.contains(bottom) {
                result.append(.bottom)
            } else if digits.contains(bottomLeft) {
                result.append(.bottomLeft)
            } else if digits.contains(bottomRight) {
                result.append(.bottomRight)
            } else {
                fatalError()
            }
        case 2:
            if digits.contains(bottomLeft) && digits.contains(bottomRight) {
                result.append(.bottomLeft)
                result.append(.bottomRight)
            } else if digits.contains(bottomLeft) && digits.contains(bottom) {
                result.append(.bottomLeftBottom)
            } else if digits.contains(bottom) && digits.contains(bottomRight) {
                result.append(.bottomBottomRight)
            } else {
                fatalError()
            }
        case 3: 
            result.append(.allBottom)
        default: 
            fatalError()
        }
        
        return result
    }
}

func getFullNumber(line: any StringProtocol, idx: String.Index) -> Int {
    var result = String(line[idx])
    
    var currentIdx = idx
    
    while true {
        guard currentIdx != line.indices.first else {
            break
        }
        
        currentIdx = line.index(before: currentIdx)
        
        let currentChar = line[currentIdx]
        
        guard digits.contains(currentChar) else {
            break
        }
        
        result.insert(currentChar, at: result.startIndex)
    }
    
    currentIdx = idx
    
    while true {
        guard currentIdx != line.indices.last else {
            break
        }
        
        currentIdx = line.index(after: currentIdx)
        
        let currentChar = line[currentIdx]
        
        guard digits.contains(currentChar) else {
            break
        }
        
        result.insert(currentChar, at: result.endIndex)
    }
    
    return Int(result)!
}

// Task 1
do {
    var sum = 0
    
    for lineIdx in 1..<lines.count-1 {
        let prevLine = lines[lineIdx-1]
        let line = lines[lineIdx]
        let nextLine = lines[lineIdx+1]
        
        var shouldAdd = false
        var numChars = [Character]()
        
        for charIdx in line.indices.dropFirst().dropLast() {
            let char = line[charIdx]
            
            if digits.contains(char) {
                numChars.append(char)
                
                let matrix = AroundMatrix(
                    topLeft: prevLine[prevLine.index(before: charIdx)], 
                    top: prevLine[charIdx], 
                    topRight: prevLine[prevLine.index(after: charIdx)],
                    left: line[line.index(before: charIdx)], 
                    right: line[line.index(after: charIdx)], 
                    bottomLeft: nextLine[nextLine.index(before: charIdx)],
                    bottom: nextLine[charIdx], 
                    bottomRight: nextLine[nextLine.index(after: charIdx)]
                )
                
                if matrix.isAdjacentToSymbol {
                    shouldAdd = true
                }
            } else {
                if shouldAdd {
                    sum += Int(numChars.map(String.init).joined())!
                }
                
                numChars.removeAll()
                shouldAdd = false
            }
        }
    }
}

// Task 2
do {
    var sum = 0
    
    for lineIdx in 1..<lines.count-1 {
        let prevLine = lines[lineIdx-1]
        let line = lines[lineIdx]
        let nextLine = lines[lineIdx+1]
        
        for charIdx in line.indices.dropFirst().dropLast() {
            let char = line[charIdx]

            if char == "*" {
                let matrix = AroundMatrix(
                    topLeft: prevLine[prevLine.index(before: charIdx)], 
                    top: prevLine[charIdx], 
                    topRight: prevLine[prevLine.index(after: charIdx)],
                    left: line[line.index(before: charIdx)], 
                    right: line[line.index(after: charIdx)], 
                    bottomLeft: nextLine[nextLine.index(before: charIdx)],
                    bottom: nextLine[charIdx], 
                    bottomRight: nextLine[nextLine.index(after: charIdx)]
                )
                
                let positions = matrix.numbersAroundPositions
                
                if positions.count == 2 {
                    var product = 1
                    
                    for pos in positions {
                        switch pos {
                        case .topLeft:
                            product *= getFullNumber(line: prevLine, idx: prevLine.index(before: charIdx))
                        case .top, .topLeftTop, .topTopRight, .allTop:
                            product *= getFullNumber(line: prevLine, idx: charIdx)
                        case .topRight:
                            product *= getFullNumber(line: prevLine, idx: prevLine.index(after: charIdx))
                        case .left:
                            product *= getFullNumber(line: line, idx: line.index(before: charIdx))
                        case .right:
                            product *= getFullNumber(line: line, idx: line.index(after: charIdx))
                        case .bottomLeft:
                            product *= getFullNumber(line: nextLine, idx: nextLine.index(before: charIdx))
                        case .bottom, .bottomLeftBottom, .bottomBottomRight, .allBottom:
                            product *= getFullNumber(line: nextLine, idx: charIdx)
                        case .bottomRight:
                            product *= getFullNumber(line: nextLine, idx: nextLine.index(after: charIdx))
                        }
                    }
                    
                    sum += product
                }
            }
        }
    }
}
