let input = "..."

let lines = input.split(separator: "\n")

let times = lines[0].split(separator: ":")[1].split(separator: " ").compactMap { Int($0)! }
let distances = lines[1].split(separator: ":")[1].split(separator: " ").compactMap { Int($0)! }

var result = 1

for i in 0..<times.count {
    let time = times[i]
    let distance = distances[i]

    var possibilities = [Int]()

    for ms in 0..<time {
        let timeLeft = time - ms
        let resultDistance = timeLeft * ms

        if resultDistance > distance {
            possibilities.append(ms)
        }
    }

    result *= possibilities.count
}