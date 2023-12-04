let input = "..."

let lines = input.split(separator: "\n")
let digits = "0123456789"

// Task 1
do {
    func getFirstDigit(from line: String) -> String? {
        if let digit = line.first(where: { digits.contains($0) }) {
            return String(digit)
        }
        
        return nil
    }
    
    func getLastDigit(from line: String) -> String? {
        if let digit = line.last(where: { digits.contains($0) }) {
            return String(digit)
        }
        
        return nil
    }
    
    let result = lines
        .compactMap { line in
            if let first = getFirstDigit(from: String(line)), let last = getLastDigit(from: String(line)) {
                return Int(first + last)
            }
            
            return nil
        }
        .reduce(0, +)
}

// Task 2
do {
    let spelledDigits = ["one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9]
    
    func getFirstDigit(from line: String) -> String? {
        var spelledIndices = [String: String.Index]()
        
        spelledDigits.keys.forEach { digit in
            let ranges = line.ranges(of: digit)
            
            if let first = ranges.first {
                spelledIndices[digit] = first.lowerBound
            }
        }
        
        let minValue = spelledIndices.values.min()
        let firstOccurrence = spelledIndices.first(where: { _, value in value == minValue })?.key
        
        let spelledDigit = spelledDigits[firstOccurrence ?? ""]
        
        // ---
        
        var digitsIndices = [Character: String.Index]()
        
        digits.forEach { digit in 
            if let idx = line.firstIndex(of: digit) {
                digitsIndices[digit] = idx
            }
        }
        
        let minDigitValue = digitsIndices.values.min()
        let firstDigitOccurrence = digitsIndices.first(where: { _, value in value == minDigitValue })?.key
        
        if let minValue, let minDigitValue {
            let spelledMinValue = line.distance(from: line.startIndex, to: minValue)
            let digitMinValue = line.distance(from: line.startIndex, to: minDigitValue)
            
            if spelledMinValue < digitMinValue, let spelledDigit {
                return String(spelledDigit)
            } else if digitMinValue < spelledMinValue, let firstDigitOccurrence {
                return String(firstDigitOccurrence)
            }
        } else if let minValue {
            if let spelledDigit {
                return String(spelledDigit)
            }
        } else if let minDigitValue {
            if let firstDigitOccurrence {
                return String(firstDigitOccurrence)
            }
        }
        
        return nil
    }
    
    func getLastDigit(from line: String) -> String? {
        var spelledIndices = [String: Int]()
        
        spelledDigits.keys.forEach { digit in
            let ranges = line.ranges(of: digit)
            
            if let last = ranges.last {
                spelledIndices[digit] = line.distance(from: line.startIndex, to: last.lowerBound)
            }
        }
        
        let maxValue = spelledIndices.values.max()
        let lastOccurrence = spelledIndices.first(where: { _, value in value == maxValue })?.key
        
        let spelledDigit = spelledDigits[lastOccurrence ?? ""]
        
        // ---
        
        var digitsIndices = [Character: Int]()
        
        digits.forEach { digit in 
            if let idx = line.lastIndex(of: digit) {
                digitsIndices[digit] = line.distance(from: line.startIndex, to: idx)
            }
        }
        
        let maxDigitValue = digitsIndices.values.max()
        let lastDigitOccurrence = digitsIndices.first(where: { _, value in value == maxDigitValue })?.key
        
        if let maxValue, let maxDigitValue {
            if maxValue > maxDigitValue, let spelledDigit {
                return String(spelledDigit)
            } else if maxDigitValue > maxValue, let lastDigitOccurrence {
                return String(lastDigitOccurrence)
            }
        } else if let maxValue {
            if let spelledDigit {
                return String(spelledDigit)
            }
        } else if let maxDigitValue {
            if let lastDigitOccurrence {
                return String(lastDigitOccurrence)
            }
        }
        
        return nil
    }
    
    let result = lines
        .compactMap { line in
            if let first = getFirstDigit(from: String(line)), let last = getLastDigit(from: String(line)) {
                return Int(first + last)
            }
            
            return nil
        }
        .reduce(0, +)
}
