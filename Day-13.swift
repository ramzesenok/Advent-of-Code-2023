let input = "..."

let fields = input.split(separator: "\n\n")

func findSolution(rows: [[String]], columns: [[String]], notRow: Int? = nil, notCol: Int? = nil) -> (horizontal: Int, vertical: Int) {
    for i in 1..<columns.count {
        if Array(columns.prefix(i)) == Array(columns.dropFirst(i).reversed().suffix(i)) {
            if i == notCol {
                continue
            }

            return (0, i)
        } else if Array(columns.suffix(columns.count - i)) == Array(columns.dropLast(columns.count - i).reversed().prefix(columns.count - i)) {
            if i == notCol {
                continue
            }

            return (0, i)
        }
    }

    for i in 1..<rows.count {
        if Array(rows.prefix(i)) == Array(rows.dropFirst(i).reversed().suffix(i)) {
            if i == notRow {
                continue
            }

            return (i, 0)
        } else if Array(rows.suffix(rows.count - i)) == Array(rows.dropLast(rows.count - i).reversed().prefix(rows.count - i)) {
            if i == notRow {
                continue
            }

            return (i, 0)
        }
    }

    return (0, 0)
}

// Task 1
do {
    var count = 0

    for field in fields {
        let rows = field.split(separator: "\n").map { line in Array(line.map { String($0) }) }
        let columns = (0..<rows[0].count).map { item in
            rows.reduce(into: [], { $0.append(Array($1)[item]) })
        }

        let (horizontalCount, verticalCount) = findSolution(rows: rows, columns: columns)

        count += verticalCount + 100 * horizontalCount
    }
}

// Task 2
do {
    var count = 0

    for field in fields {
        for i in 0..<field.count - field.filter({ $0 == "\n" }).count {
            var rows = field.split(separator: "\n").map { line in Array(line.map { String($0) }) }
            var columns = (0..<rows[0].count).map { item in
                rows.reduce(into: [], { $0.append(Array($1)[item]) })
            }

            let (originalHorizontalCount, originalVerticalCount) = findSolution(rows: rows, columns: columns)

            let (rowIdx, colIdx) = (i / (columns.count), i % (columns.count))

            rows[rowIdx][colIdx] = rows[rowIdx][colIdx].inverted
            columns[colIdx][rowIdx] = columns[colIdx][rowIdx].inverted

            let (horizontalCount, verticalCount) = findSolution(
                rows: rows,
                columns: columns,
                notRow: originalHorizontalCount,
                notCol: originalVerticalCount
            )

            if horizontalCount > 0 || verticalCount > 0 {
                count += verticalCount + 100 * horizontalCount
                break
            }
        }
    }
}


extension String {
    var inverted: String {
        switch self {
        case ".": "#"
        case "#": "."
        default: fatalError()
        }
    }
}
