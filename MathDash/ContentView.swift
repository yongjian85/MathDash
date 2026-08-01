//
//  ContentView.swift
//  MathDash
//
//  Created by yong jian on 2026-07-29.
//

import SwiftUI
import Combine
import AudioToolbox

enum Operation {
    case add
    case subtract
    case multiplySmall
    case multiplyBig
    case divide
    case fractionOfWhole
    case fractionAdd

    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "−"
        case .multiplySmall, .multiplyBig: return "×"
        case .divide: return "÷"
        case .fractionOfWhole: return "of"
        case .fractionAdd: return "+"
        }
    }

    var shortName: String {
        switch self {
        case .add: return "add"
        case .subtract: return "subtract"
        case .multiplySmall: return "multiply"
        case .multiplyBig: return "big ×"
        case .divide: return "divide"
        case .fractionOfWhole: return "fractions"
        case .fractionAdd: return "fractions"
        }
    }
}

enum GameMode: String, CaseIterable, Identifiable {
    case addition
    case subtraction
    case multiplication
    case division
    case fractions
    case challenge
    case mix

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addition: return "Add It Up"
        case .subtraction: return "Take Away"
        case .multiplication: return "Times Tables"
        case .division: return "Divide"
        case .fractions: return "Fractions"
        case .challenge: return "Challenge"
        case .mix: return "Mix It Up"
        }
    }

    func subtitle(for age: AgeGroup) -> String {
        let d = age.difficulty
        switch self {
        case .addition:
            return "\(d.addLeft.lowerBound)–\(d.addLeft.upperBound) + \(d.addRight.lowerBound)–\(d.addRight.upperBound)"
        case .subtraction:
            return "\(d.subtractLeft.lowerBound)–\(d.subtractLeft.upperBound) − \(d.subtractRight.lowerBound)–\(d.subtractRight.upperBound)"
        case .multiplication:
            if age == .g4to5 || age == .adult {
                return "up to \(d.bigMultLeft.upperBound) × \(d.bigMultRight.upperBound)"
            }
            return "\(d.smallMultLeft.lowerBound)–\(d.smallMultLeft.upperBound) × \(d.smallMultRight.lowerBound)–\(d.smallMultRight.upperBound)"
        case .division:
            let maxDividend = d.divideDivisor.upperBound * d.divideQuotient.upperBound
            return "up to \(maxDividend) ÷ \(d.divideDivisor.lowerBound)–\(d.divideDivisor.upperBound)"
        case .fractions:
            return "n⁄\(d.fractionDenominator.upperBound) of a whole"
        case .challenge:
            return "n⁄d + n⁄d"
        case .mix:
            let names = age.mixOperations.map { $0.shortName }
            switch names.count {
            case 0: return "—"
            case 1: return names[0]
            case 2: return "\(names[0]) & \(names[1])"
            default:
                let head = names.dropLast().joined(separator: ", ")
                return "\(head) & \(names.last!)"
            }
        }
    }

    var icon: String {
        switch self {
        case .addition: return "plus.circle.fill"
        case .subtraction: return "minus.circle.fill"
        case .multiplication: return "multiply.circle.fill"
        case .division: return "divide.circle.fill"
        case .fractions: return "chart.pie.fill"
        case .challenge: return "flame.fill"
        case .mix: return "die.face.5.fill"
        }
    }

    var color: Color {
        switch self {
        case .addition: return Color(red: 0.35, green: 0.55, blue: 0.95)
        case .subtraction: return Color(red: 0.3, green: 0.75, blue: 0.6)
        case .multiplication: return Color(red: 0.75, green: 0.4, blue: 0.9)
        case .division: return Color(red: 0.9, green: 0.4, blue: 0.55)
        case .fractions: return Color(red: 0.85, green: 0.6, blue: 0.15)
        case .challenge: return Color(red: 0.82, green: 0.28, blue: 0.4)
        case .mix: return Color(red: 0.95, green: 0.5, blue: 0.3)
        }
    }

    func nextOperation(for age: AgeGroup) -> Operation {
        switch self {
        case .addition: return .add
        case .subtraction: return .subtract
        case .multiplication:
            if age == .g4to5 || age == .adult {
                return Bool.random() ? .multiplySmall : .multiplyBig
            }
            return .multiplySmall
        case .division: return .divide
        case .fractions: return .fractionOfWhole
        case .challenge: return .fractionAdd
        case .mix: return age.mixOperations.randomElement() ?? .add
        }
    }
}

enum AgeGroup: String, CaseIterable, Identifiable {
    case jkG1
    case g2to3
    case g4to5
    case adult

    var id: String { rawValue }

    var title: String {
        switch self {
        case .jkG1: return "JK – Grade 1"
        case .g2to3: return "Grade 2 – 3"
        case .g4to5: return "Grade 4 – 5"
        case .adult: return "Challenge"
        }
    }

    var subtitle: String {
        switch self {
        case .jkG1: return "Gentle single-digit fun"
        case .g2to3: return "Small 2-digit adds"
        case .g4to5: return "Full 2-digit & times tables"
        case .adult: return "Big numbers, no mercy"
        }
    }

    var icon: String {
        switch self {
        case .jkG1: return "figure.and.child.holdinghands"
        case .g2to3: return "book.fill"
        case .g4to5: return "graduationcap.fill"
        case .adult: return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .jkG1: return Color(red: 0.3, green: 0.75, blue: 0.6)
        case .g2to3: return Color(red: 0.4, green: 0.6, blue: 0.95)
        case .g4to5: return Color(red: 0.75, green: 0.4, blue: 0.9)
        case .adult: return Color(red: 0.95, green: 0.4, blue: 0.35)
        }
    }

    var availableModes: [GameMode] {
        switch self {
        case .jkG1: return [.addition, .subtraction, .multiplication, .mix]
        case .g2to3: return [.addition, .subtraction, .multiplication, .division, .fractions, .mix]
        case .g4to5: return [.addition, .subtraction, .multiplication, .division, .mix]
        case .adult: return [.addition, .subtraction, .multiplication, .division, .challenge, .mix]
        }
    }

    var mixOperations: [Operation] {
        var ops: [Operation] = []
        for mode in availableModes where mode != .mix {
            switch mode {
            case .addition: ops.append(.add)
            case .subtraction: ops.append(.subtract)
            case .multiplication:
                ops.append(.multiplySmall)
                if self == .g4to5 || self == .adult {
                    ops.append(.multiplyBig)
                }
            case .division: ops.append(.divide)
            case .fractions: ops.append(.fractionOfWhole)
            // Challenge (fraction addition) stays out of Mix — it's its own mode.
            case .challenge: break
            case .mix: break
            }
        }
        return ops
    }

    var questionTimeLimit: Double {
        switch self {
        case .jkG1: return 10.0
        case .g2to3: return 8.0
        case .g4to5: return 7.0
        case .adult: return 6.0
        }
    }

    var difficulty: Difficulty {
        switch self {
        case .jkG1:
            return Difficulty(
                addLeft: 1...9, addRight: 1...9, addDelta: -5...5,
                subtractLeft: 2...9, subtractRight: 1...9, subtractDelta: -5...5,
                smallMultLeft: 1...5, smallMultRight: 1...5, smallMultDelta: -6...6,
                bigMultLeft: 1...5, bigMultRight: 1...5, bigMultDelta: -6...6,
                divideDivisor: 1...2, divideQuotient: 1...2, divideDelta: -3...3,
                fractionDenominator: 2...4, fractionMultiplier: 2...5, fractionDelta: -4...4
            )
        case .g2to3:
            return Difficulty(
                addLeft: 10...50, addRight: 10...50, addDelta: -12...12,
                subtractLeft: 10...50, subtractRight: 1...50, subtractDelta: -12...12,
                smallMultLeft: 2...9, smallMultRight: 2...9, smallMultDelta: -10...10,
                bigMultLeft: 2...9, bigMultRight: 2...9, bigMultDelta: -10...10,
                divideDivisor: 2...9, divideQuotient: 2...9, divideDelta: -8...8,
                fractionDenominator: 2...5, fractionMultiplier: 2...6, fractionDelta: -5...5
            )
        case .g4to5:
            return Difficulty(
                addLeft: 10...99, addRight: 10...99, addDelta: -15...15,
                subtractLeft: 10...99, subtractRight: 1...99, subtractDelta: -15...15,
                smallMultLeft: 2...9, smallMultRight: 2...9, smallMultDelta: -10...10,
                bigMultLeft: 10...99, bigMultRight: 2...9, bigMultDelta: -40...40,
                divideDivisor: 2...9, divideQuotient: 2...16, divideDelta: -8...8,
                fractionDenominator: 2...9, fractionMultiplier: 2...8, fractionDelta: -8...8
            )
        case .adult:
            return Difficulty(
                addLeft: 100...999, addRight: 10...99, addDelta: -50...50,
                subtractLeft: 100...999, subtractRight: 10...999, subtractDelta: -50...50,
                smallMultLeft: 2...9, smallMultRight: 2...9, smallMultDelta: -10...10,
                bigMultLeft: 10...99, bigMultRight: 2...9, bigMultDelta: -40...40,
                divideDivisor: 2...12, divideQuotient: 2...12, divideDelta: -12...12,
                fractionDenominator: 2...9, fractionMultiplier: 2...12, fractionDelta: -12...12
            )
        }
    }
}

struct Difficulty {
    let addLeft: ClosedRange<Int>
    let addRight: ClosedRange<Int>
    let addDelta: ClosedRange<Int>
    let subtractLeft: ClosedRange<Int>
    let subtractRight: ClosedRange<Int>
    let subtractDelta: ClosedRange<Int>
    let smallMultLeft: ClosedRange<Int>
    let smallMultRight: ClosedRange<Int>
    let smallMultDelta: ClosedRange<Int>
    let bigMultLeft: ClosedRange<Int>
    let bigMultRight: ClosedRange<Int>
    let bigMultDelta: ClosedRange<Int>
    let divideDivisor: ClosedRange<Int>
    let divideQuotient: ClosedRange<Int>
    let divideDelta: ClosedRange<Int>
    let fractionDenominator: ClosedRange<Int>
    let fractionMultiplier: ClosedRange<Int>
    let fractionDelta: ClosedRange<Int>
}

enum GamePhase {
    case welcome, selectMode, playing, gameOver, leaderboard
}

extension View {
    /// Swipeable, dot-paged style for the leaderboard (iOS-only page style).
    @ViewBuilder
    func pagedLeaderboardStyle() -> some View {
        #if os(iOS)
        self
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        #else
        self
        #endif
    }
}

struct ScoreEntry: Codable, Identifiable {
    let id: UUID
    let name: String
    let score: Int
    let mode: String
    let date: Date
}

final class Leaderboard: ObservableObject {
    static let maxPerMode = 10
    private static let storeKey = "mathdash.leaderboard.v1"

    @Published private(set) var entries: [ScoreEntry] = []

    init() {
        load()
    }

    func top(for mode: GameMode) -> [ScoreEntry] {
        entries
            .filter { $0.mode == mode.rawValue }
            .sorted { $0.score > $1.score }
    }

    func qualifies(score: Int, mode: GameMode) -> Bool {
        guard score > 0 else { return false }
        let modeEntries = top(for: mode)
        if modeEntries.count < Self.maxPerMode { return true }
        return score > (modeEntries.last?.score ?? 0)
    }

    @discardableResult
    func add(name: String, score: Int, mode: GameMode) -> UUID {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let entry = ScoreEntry(
            id: UUID(),
            name: trimmed.isEmpty ? "Player" : trimmed,
            score: score,
            mode: mode.rawValue,
            date: Date()
        )
        entries.append(entry)
        trimToTop()
        save()
        return entry.id
    }

    private func trimToTop() {
        var kept: [ScoreEntry] = []
        for mode in GameMode.allCases {
            let ranked = entries
                .filter { $0.mode == mode.rawValue }
                .sorted { $0.score > $1.score }
                .prefix(Self.maxPerMode)
            kept.append(contentsOf: ranked)
        }
        entries = kept
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storeKey),
              let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return
        }
        entries = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: Self.storeKey)
        }
    }
}

struct Fraction: Equatable {
    let num: Int
    let den: Int

    init(_ num: Int, _ den: Int) {
        let g = max(1, Fraction.gcd(abs(num), abs(den)))
        let sign = den < 0 ? -1 : 1
        self.num = sign * num / g
        self.den = abs(den) / g
    }

    static func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a, b = b
        while b != 0 { (a, b) = (b, a % b) }
        return max(a, 1)
    }

    static func + (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.num * rhs.den + rhs.num * lhs.den, lhs.den * rhs.den)
    }
}

struct Question {
    let left: Int
    let right: Int
    let operation: Operation
    let whole: Int?
    let choices: [Int]
    let answer: Int
    var fractionOperands: [Fraction]? = nil
    var fractionOptions: [Fraction]? = nil

    static func random(mode: GameMode, age: AgeGroup) -> Question {
        let op = mode.nextOperation(for: age)
        let d = age.difficulty
        let left: Int
        let right: Int
        let answer: Int
        let deltaRange: ClosedRange<Int>
        var whole: Int? = nil

        switch op {
        case .add:
            left = Int.random(in: d.addLeft)
            right = Int.random(in: d.addRight)
            answer = left + right
            deltaRange = d.addDelta
        case .subtract:
            let a = Int.random(in: d.subtractLeft)
            let b = Int.random(in: d.subtractRight)
            left = max(a, b)
            right = min(a, b)
            answer = left - right
            deltaRange = d.subtractDelta
        case .multiplySmall:
            left = Int.random(in: d.smallMultLeft)
            right = Int.random(in: d.smallMultRight)
            answer = left * right
            deltaRange = d.smallMultDelta
        case .multiplyBig:
            left = Int.random(in: d.bigMultLeft)
            right = Int.random(in: d.bigMultRight)
            answer = left * right
            deltaRange = d.bigMultDelta
        case .divide:
            let divisor = Int.random(in: d.divideDivisor)
            let quotient = Int.random(in: d.divideQuotient)
            left = divisor * quotient
            right = divisor
            answer = quotient
            deltaRange = d.divideDelta
        case .fractionOfWhole:
            let denominator = Int.random(in: d.fractionDenominator)
            let numerator = Int.random(in: 1...max(1, denominator - 1))
            let multiplier = Int.random(in: d.fractionMultiplier)
            left = numerator
            right = denominator
            whole = denominator * multiplier
            answer = numerator * multiplier
            deltaRange = d.fractionDelta
        case .fractionAdd:
            return fractionAddQuestion()
        }

        var options: Set<Int> = [answer]
        var matchingCount = 0
        let targetMatching = Int.random(in: 1...3)

        let tensSteps = (1...6).flatMap { [$0 * 10, -$0 * 10] }.shuffled()
        for step in tensSteps {
            if matchingCount >= targetMatching || options.count >= 4 { break }
            let candidate = answer + step
            if candidate >= 0 && !options.contains(candidate) {
                options.insert(candidate)
                matchingCount += 1
            }
        }

        var attempts = 0
        while options.count < 4 && attempts < 50 {
            attempts += 1
            let delta = Int.random(in: deltaRange)
            let candidate = answer + delta
            if candidate >= 0 && candidate != answer {
                options.insert(candidate)
            }
        }

        var pad = 1
        while options.count < 4 && pad < 1000 {
            let candidate = answer + pad
            if candidate >= 0 { options.insert(candidate) }
            pad += 1
        }

        return Question(
            left: left,
            right: right,
            operation: op,
            whole: whole,
            choices: options.shuffled(),
            answer: answer
        )
    }

    // Fraction + fraction (numerator 1–9, denominator 2–9). Choices are indices
    // into `fractionOptions`, so the Int-based answer/scoring pipeline is reused.
    static func fractionAddQuestion() -> Question {
        // Keep both addends and the sum as true fractions — no whole numbers.
        var f1 = Fraction(Int.random(in: 1...9), Int.random(in: 2...9))
        var f2 = Fraction(Int.random(in: 1...9), Int.random(in: 2...9))
        while f1.den == 1 || f2.den == 1 || (f1 + f2).den == 1 {
            f1 = Fraction(Int.random(in: 1...9), Int.random(in: 2...9))
            f2 = Fraction(Int.random(in: 1...9), Int.random(in: 2...9))
        }
        let answer = f1 + f2

        var options: [Fraction] = [answer]
        func tryAdd(_ f: Fraction) {
            if f.num > 0 && f.den > 1 && !options.contains(f) {
                options.append(f)
            }
        }

        // Classic mistake: add tops and bottoms.
        tryAdd(Fraction(f1.num + f2.num, f1.den + f2.den))
        // Near misses on the reduced answer.
        tryAdd(Fraction(answer.num + 1, answer.den))
        tryAdd(Fraction(max(1, answer.num - 1), answer.den))
        tryAdd(Fraction(answer.num, answer.den + 1))

        var attempts = 0
        while options.count < 4 && attempts < 60 {
            attempts += 1
            tryAdd(Fraction(Int.random(in: 1...9), Int.random(in: 2...9)))
        }
        var extra = 2
        while options.count < 4 {
            tryAdd(Fraction(answer.num + extra, answer.den))
            extra += 1
        }

        let shuffled = Array(options.prefix(4)).shuffled()
        let answerIndex = shuffled.firstIndex(of: answer) ?? 0
        return Question(
            left: f1.num,
            right: f2.num,
            operation: .fractionAdd,
            whole: nil,
            choices: Array(0..<shuffled.count),
            answer: answerIndex,
            fractionOperands: [f1, f2],
            fractionOptions: shuffled
        )
    }
}

struct ContentView: View {
    private static let gameDuration: Double = 60.0
    private static let tickInterval: Double = 0.05

    private static let maxPoints = 10
    private static let minPoints = 1
    private static let pointsDecayRate: Double = 0.35
    private static let wrongPenalty = 3

    private static let playerNameKey = "mathdash.playerName"
    private static let ageGroupKey = "mathdash.ageGroup"
    private static let focusModeKey = "mathdash.focusMode"

    @StateObject private var leaderboard = Leaderboard()
    @State private var phase: GamePhase = .welcome
    @State private var focusMode: Bool = UserDefaults.standard.bool(forKey: ContentView.focusModeKey)
    @State private var mode: GameMode = .addition
    @State private var age: AgeGroup = {
        let raw = UserDefaults.standard.string(forKey: ContentView.ageGroupKey) ?? ""
        return AgeGroup(rawValue: raw) ?? .g2to3
    }()
    @State private var leaderboardMode: GameMode = .addition
    @State private var playerName: String = UserDefaults.standard.string(forKey: ContentView.playerNameKey) ?? ""
    @State private var hasSubmittedScore = false
    @FocusState private var nameFieldFocused: Bool
    @State private var question = Question.random(mode: .addition, age: .g2to3)
    @State private var score = 0
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var correctCount = 0
    @State private var selected: Int? = nil
    @State private var timeRemaining: Double = ContentView.gameDuration
    @State private var questionElapsed: Double = 0
    @State private var pointsPopup: Int? = nil
    @State private var bonusPopup: Int? = nil
    @State private var didTimeOut = false
    @State private var showQuitConfirmation = false
    @State private var newEntryID: UUID? = nil
    @State private var climbRemaining = 0
    @State private var climbStarted = false
    /// Once true, every leaderboard score is shown; while false, scores hidden
    /// as "???" per the mystery reveal during the post-game climb.
    @State private var revealAllScores = false
    @State private var timerBarWidth: CGFloat = 0
    @State private var iconEntryOffset: CGFloat = 0

    private var isAnswered: Bool { selected != nil || didTimeOut }
    private var timeFraction: Double { timeRemaining / Self.gameDuration }

    private var currentPoints: Int {
        let decayed = Double(Self.maxPoints) * exp(-Self.pointsDecayRate * questionElapsed)
        return max(Self.minPoints, min(Self.maxPoints, Int(decayed.rounded())))
    }

    private var questionSecondsLeft: Int {
        max(0, Int(ceil(age.questionTimeLimit - questionElapsed)))
    }

    private var isOnFire: Bool { streak >= 3 }

    /// Fun mode gets the bright playful gradient; Focus mode gets a calm slate
    /// backdrop so nothing competes with the math.
    private var backgroundGradient: LinearGradient {
        if focusMode {
            return LinearGradient(
                colors: [Color(red: 0.44, green: 0.49, blue: 0.58), Color(red: 0.56, green: 0.60, blue: 0.68)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(red: 0.55, green: 0.85, blue: 1.0), Color(red: 0.85, green: 0.75, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            switch phase {
            case .welcome: welcomeView
            case .selectMode: selectModeView
            case .playing: gameView
            case .gameOver: gameOverView
            case .leaderboard: leaderboardView
            }
        }
        .onReceive(Timer.publish(every: Self.tickInterval, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
    }

    // MARK: - Welcome (age selection)

    private var welcomeView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Math Dash")
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                Text("Who's playing?")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.top, 20)

            modeToggle

            VStack(spacing: 14) {
                ForEach(AgeGroup.allCases) { g in
                    Button {
                        selectAge(g)
                    } label: {
                        ageCard(g)
                    }
                }
            }

            Button {
                leaderboardMode = mode
                phase = .leaderboard
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                .background(
                    Capsule().fill(Color.white.opacity(0.25))
                )
            }

            Spacer()
        }
        .padding(24)
    }

    // Fun vs Focus experience picker. Focus strips every non-essential visual
    // (vehicle, flames, popups, sound, bright colors) so play stays distraction-free.
    private var modeToggle: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                ForEach([false, true], id: \.self) { focus in
                    let isSelected = focusMode == focus
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { setFocusMode(focus) }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: focus ? "leaf.fill" : "sparkles")
                            Text(focus ? "Focus" : "Fun")
                        }
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(isSelected ? Color(red: 0.2, green: 0.2, blue: 0.4) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(isSelected ? Color.white : Color.clear)
                        )
                    }
                }
            }
            .padding(4)
            .background(Capsule().fill(Color.white.opacity(0.25)))

            Text(focusMode ? "No distractions — just the math." : "Vehicles, streaks & flair.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
    }

    private func ageCard(_ g: AgeGroup) -> some View {
        HStack(spacing: 18) {
            Image(systemName: g.icon)
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(.white)
                .frame(width: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(g.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                Text(g.subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .opacity(0.85)
            }
            .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(g.color)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        )
    }

    // MARK: - Mode selection

    private var selectModeView: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: backToWelcome) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.25)))
                }
                Spacer()
                Text("Pick a mode")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }

            HStack(spacing: 10) {
                Image(systemName: age.icon)
                    .font(.system(size: 18, weight: .heavy))
                Text(age.title)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(Capsule().fill(age.color))
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            Spacer()

            VStack(spacing: 16) {
                ForEach(age.availableModes) { m in
                    Button {
                        start(mode: m)
                    } label: {
                        modeCard(m)
                    }
                }
            }

            Spacer()
        }
        .padding(24)
    }

    private func modeCard(_ m: GameMode) -> some View {
        HStack(spacing: 18) {
            Image(systemName: m.icon)
                .font(.system(size: 40, weight: .heavy))
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 4) {
                Text(m.title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                Text(m.subtitle(for: age))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .opacity(0.85)
            }
            .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(m.color)
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        )
    }

    // MARK: - Game

    private var gameView: some View {
        VStack(spacing: 24) {
            header

            timerBar
                .padding(.horizontal, -12)

            Spacer()

            questionCard

            choicesGrid

            Spacer()
        }
        .padding(24)
        .alert("Quit this round?", isPresented: $showQuitConfirmation) {
            Button("Keep Playing", role: .cancel) { }
            Button("Quit", role: .destructive) { backToMenu() }
        } message: {
            Text("The timer keeps running while you decide.")
        }
    }

    // MARK: - Game Over

    private var gameOverView: some View {
        let showNameEntry = leaderboard.qualifies(score: score, mode: mode) && !hasSubmittedScore

        return VStack(spacing: 24) {
            Text(showNameEntry ? "New High Score!" : "Time's Up!")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

            VStack(spacing: 16) {
                resultRow(label: "Mode", value: mode.title, color: mode.color)
                resultRow(label: "Final Score", value: "\(score)", color: .orange)
                resultRow(label: "Best Streak", value: "\(bestStreak)", color: .pink)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
            )

            if showNameEntry {
                nameEntryCard
            }

            VStack(spacing: 12) {
                Button {
                    start(mode: mode)
                } label: {
                    Text("Play Again")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(mode.color)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                        )
                }
                HStack(spacing: 12) {
                    Button {
                        leaderboardMode = mode
                        phase = .leaderboard
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                            Text("Leaderboard")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.25))
                        )
                    }
                    Button(action: backToMenu) {
                        Text("Change Mode")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.25))
                            )
                    }
                }
            }
        }
        .padding(24)
    }

    private var nameEntryCard: some View {
        VStack(spacing: 12) {
            Text("Enter your name")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
            HStack(spacing: 10) {
                TextField("Name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .focused($nameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit(submitScore)
                Button(action: submitScore) {
                    Text("Save")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(mode.color)
                        )
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .onAppear { nameFieldFocused = true }
    }

    // MARK: - Leaderboard

    private var leaderboardView: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: leaveLeaderboard) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.white.opacity(0.25)))
                }
                Spacer()
                Text("Leaderboard")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }

            TabView(selection: $leaderboardMode) {
                ForEach(GameMode.allCases) { mode in
                    leaderboardPage(mode: mode)
                        .tag(mode)
                }
            }
            .pagedLeaderboardStyle()
            .frame(maxHeight: .infinity)
        }
        .padding(24)
    }

    @ViewBuilder
    private func leaderboardPage(mode: GameMode) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.system(size: 22, weight: .heavy))
                Text(mode.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

            let entries = leaderboard.top(for: mode)
            if entries.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.white.opacity(0.8))
                    Text("No scores yet")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            } else {
                let newIndex = entries.firstIndex { $0.id == newEntryID }
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            let isNew = entry.id == newEntryID
                            let revealed = scoreRevealed(index: index, isNew: isNew, newIndex: newIndex)
                            leaderboardRow(rank: index + 1, entry: entry, isNew: isNew, revealed: revealed)
                                .offset(y: isNew ? CGFloat(climbRemaining) * Self.leaderboardRowHeight : 0)
                                .zIndex(isNew ? 1 : 0)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 12)
                }
                .onAppear {
                    guard entries.contains(where: { $0.id == newEntryID }), !climbStarted else { return }
                    climbStarted = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        stepClimb()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.bottom, 30)
    }

    /// Approximate on-screen height of one leaderboard row (incl. spacing), used
    /// to offset a climbing entry by whole rows as it passes each lower score.
    private static let leaderboardRowHeight: CGFloat = 76

    /// Whether a row's score should be shown (vs. hidden as "???") during the
    /// mysterious post-game climb. Lower scores reveal one-by-one as the new
    /// entry climbs past them; higher scores stay hidden until `revealAllScores`
    /// flips 1s after the climb settles.
    private func scoreRevealed(index: Int, isNew: Bool, newIndex: Int?) -> Bool {
        if revealAllScores { return true }
        // Own score is always visible so the player can watch it climb.
        if isNew { return true }
        // Not in a post-game climb for this page → nothing is hidden.
        guard let newIndex else { return true }
        if index > newIndex {
            // A lower score: revealed once the climbing entry has passed it.
            // The new entry's current visual position is newIndex + climbRemaining.
            return newIndex + climbRemaining < index
        }
        // A higher score: stays "???" until the whole board unlocks.
        return false
    }

    private func leaderboardRow(rank: Int, entry: ScoreEntry, isNew: Bool = false, revealed: Bool = true) -> some View {
        HStack(spacing: 14) {
            rankBadge(rank: rank)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                Text(entry.date, style: .date)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.55))
            }
            Spacer()
            Text(revealed ? "\(entry.score)" : "???")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(revealed ? .orange : Color(red: 0.65, green: 0.65, blue: 0.75))
                .monospacedDigit()
                .contentTransition(.opacity)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: isNew ? .orange.opacity(0.5) : .black.opacity(0.1),
                        radius: isNew ? 8 : 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.orange, lineWidth: isNew ? 3 : 0)
        )
    }

    private func rankBadge(rank: Int) -> some View {
        ZStack {
            Circle()
                .fill(rankGradient(rank))
                .frame(width: 44, height: 44)
                .shadow(color: rankShadow(rank), radius: rank <= 3 ? 6 : 3, y: 2)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(rank <= 3 ? 0.5 : 0), lineWidth: 1.5)
                )
            Group {
                switch rank {
                case 1:
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20, weight: .heavy))
                case 2, 3:
                    Image(systemName: "medal.fill")
                        .font(.system(size: 20, weight: .heavy))
                default:
                    Text("\(rank)")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
        }
    }

    private func rankGradient(_ rank: Int) -> LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.87, blue: 0.35), Color(red: 0.95, green: 0.62, blue: 0.05)],
                startPoint: .top, endPoint: .bottom
            )
        case 2:
            return LinearGradient(
                colors: [Color(red: 0.93, green: 0.94, blue: 0.97), Color(red: 0.63, green: 0.67, blue: 0.76)],
                startPoint: .top, endPoint: .bottom
            )
        case 3:
            return LinearGradient(
                colors: [Color(red: 0.92, green: 0.66, blue: 0.42), Color(red: 0.62, green: 0.35, blue: 0.15)],
                startPoint: .top, endPoint: .bottom
            )
        default:
            return LinearGradient(
                colors: [Color(red: 0.55, green: 0.60, blue: 0.78), Color(red: 0.45, green: 0.50, blue: 0.68)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    private func rankShadow(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.55)
        case 2: return Color(red: 0.7, green: 0.72, blue: 0.8).opacity(0.5)
        case 3: return Color(red: 0.75, green: 0.45, blue: 0.2).opacity(0.55)
        default: return .black.opacity(0.15)
        }
    }

    private func resultRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
            Spacer()
            Text(value)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(color)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                showQuitConfirmation = true
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.25)))
            }
            scoreChip(label: "Score", value: score, color: .orange)
            Spacer()
            scoreChip(
                label: "Streak",
                value: streak,
                color: (!focusMode && isOnFire) ? Color(red: 0.95, green: 0.35, blue: 0.15) : .pink,
                showFlame: !focusMode && isOnFire
            )
        }
    }

    private func scoreChip(label: String, value: Int, color: Color, showFlame: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.9))
            HStack(spacing: 6) {
                if showFlame {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .modifier(FlamePulse())
                        .transition(.scale.combined(with: .opacity))
                }
                Text("\(value)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
        }
        .frame(minWidth: 90)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .shadow(color: showFlame ? .orange.opacity(0.6) : .black.opacity(0.15), radius: showFlame ? 10 : 6, y: 3)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showFlame)
    }

    // Vehicle progression: upgrades one stage per 3 correct answers.
    private static let vehicleStages = ["👶", "🚲", "🏍️", "🚐", "🏎️", "🚄", "🛩️", "✈️", "🚀"]

    private var vehicleIcon: String {
        let stage = min(correctCount / 3, Self.vehicleStages.count - 1)
        return Self.vehicleStages[stage]
    }

    private var timerBar: some View {
        GeometryReader { geo in
            let fillWidth = max(0, geo.size.width * timeFraction)
            let vehicleSize: CGFloat = 90
            let vehicleX = min(max(fillWidth - vehicleSize / 2, 0), geo.size.width - vehicleSize)
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 28)
                RoundedRectangle(cornerRadius: 12)
                    .fill(timerColor)
                    .frame(width: fillWidth, height: 28)
                    .animation(.linear(duration: Self.tickInterval), value: timeRemaining)
                Text(String(format: "%.1fs", max(0, timeRemaining)))
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                if !focusMode {
                    Text(vehicleIcon)
                        .font(.system(size: 66))
                        // vehicleX tracks the current-time tip (sub-pixel per tick, so no
                        // smoothing modifier needed); iconEntryOffset is the entry slide.
                        .frame(width: vehicleSize, height: vehicleSize)
                        // Swap the emoji instantly — only the slide (below) animates.
                        .animation(nil, value: vehicleIcon)
                        .offset(x: vehicleX + iconEntryOffset, y: -8)
                }
            }
            .onAppear { timerBarWidth = geo.size.width }
            .onChange(of: geo.size.width) { _ in timerBarWidth = geo.size.width }
            .onChange(of: vehicleIcon) { _ in
                guard !focusMode else { return }
                slideIconIn(vehicleSize: vehicleSize)
            }
        }
        .frame(height: focusMode ? 28 : 78)
    }

    /// Snap the icon to the right end of the bar, then slide it to the current
    /// remaining-time position — runs every time the vehicle icon upgrades.
    private func slideIconIn(vehicleSize: CGFloat) {
        guard timerBarWidth > vehicleSize else { return }
        let fillWidth = max(0, timerBarWidth * timeFraction)
        let vehicleX = min(max(fillWidth - vehicleSize / 2, 0), timerBarWidth - vehicleSize)
        let rightEnd = timerBarWidth - vehicleSize

        // Snap to the right end without animation.
        var snap = Transaction()
        snap.disablesAnimations = true
        withTransaction(snap) { iconEntryOffset = rightEnd - vehicleX }

        // Let that frame render, then slowly slide the icon left to catch up
        // with the current remaining-time tip.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            withAnimation(.easeOut(duration: 1.6)) {
                iconEntryOffset = 0
            }
        }
    }

    private var timerColor: Color {
        switch timeFraction {
        case ..<0.2: return .red
        case ..<0.5: return .orange
        default: return .green
        }
    }

    // MARK: - Question

    private static let inkColor = Color(red: 0.2, green: 0.2, blue: 0.4)

    @ViewBuilder
    private var questionContent: some View {
        if question.operation == .fractionAdd, let ops = question.fractionOperands, ops.count == 2 {
            fractionAddView(ops[0], ops[1])
        } else if question.operation == .fractionOfWhole, let whole = question.whole {
            fractionOfWholeView(numerator: question.left, denominator: question.right, whole: whole)
        } else {
            standardArithmeticView
        }
    }

    private func fractionView(_ f: Fraction, fontSize: CGFloat, color: Color) -> some View {
        Group {
            if f.den == 1 {
                Text("\(f.num)")
            } else {
                VStack(spacing: 2) {
                    Text("\(f.num)")
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color)
                        .frame(width: fontSize * 0.95, height: max(2, fontSize * 0.08))
                    Text("\(f.den)")
                }
            }
        }
        .font(.system(size: fontSize, weight: .heavy, design: .rounded))
        .monospacedDigit()
        .foregroundColor(color)
        .fixedSize()
    }

    private func fractionAddView(_ a: Fraction, _ b: Fraction) -> some View {
        HStack(spacing: 16) {
            fractionView(a, fontSize: 46, color: Self.inkColor)
            Text("+")
            fractionView(b, fontSize: 46, color: Self.inkColor)
            Text("=")
            Text("?")
        }
        .font(.system(size: 40, weight: .heavy, design: .rounded))
        .monospacedDigit()
        .foregroundColor(Self.inkColor)
    }

    private var standardArithmeticView: some View {
        Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 4) {
            GridRow {
                Text(" ")
                Text("\(question.left)")
            }
            GridRow {
                Text(question.operation.symbol)
                Text("\(question.right)")
            }
            Rectangle()
                .fill(Color(red: 0.2, green: 0.2, blue: 0.4))
                .frame(height: 4)
                .gridCellColumns(2)
            GridRow {
                Text(" ")
                Text("?")
            }
        }
        .font(.system(size: 56, weight: .heavy, design: .rounded))
        .monospacedDigit()
        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
    }

    private func fractionOfWholeView(numerator: Int, denominator: Int, whole: Int) -> some View {
        HStack(spacing: 18) {
            VStack(spacing: 4) {
                Text("\(numerator)")
                Rectangle()
                    .fill(Color(red: 0.2, green: 0.2, blue: 0.4))
                    .frame(height: 4)
                Text("\(denominator)")
            }
            .fixedSize()
            Text("of")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
            Text("\(whole)")
            Text("=")
            Text("?")
        }
        .font(.system(size: 52, weight: .heavy, design: .rounded))
        .monospacedDigit()
        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
    }

    private var questionCard: some View {
        ZStack(alignment: .topTrailing) {
            questionContent
                .padding(.horizontal, 48)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
                )

            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .heavy))
                Text("\(isAnswered ? 0 : questionSecondsLeft)s")
                    .contentTransition(.numericText())
                Text("·")
                    .opacity(0.6)
                Text("\(isAnswered ? 0 : currentPoints) pts")
            }
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(pointsBadgeColor)
            )
            .padding(12)
            .animation(.easeInOut(duration: 0.2), value: currentPoints)
            .animation(.easeInOut(duration: 0.2), value: questionSecondsLeft)

            if !focusMode, let pointsPopup {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(pointsPopup >= 0 ? "+\(pointsPopup)" : "\(pointsPopup)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(pointsPopup >= 0 ? .green : .red)
                    if let bonusPopup {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(
                                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                                )
                            Text("+\(bonusPopup)")
                                .foregroundColor(.orange)
                        }
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                .padding(20)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
    }

    private var pointsBadgeColor: Color {
        switch currentPoints {
        case 8...: return .green
        case 5...: return .orange
        default: return .red
        }
    }

    private var choicesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
            ForEach(Array(question.choices.enumerated()), id: \.element) { index, choice in
                Button {
                    tap(choice)
                } label: {
                    Group {
                        if question.operation == .fractionAdd,
                           let opts = question.fractionOptions, choice < opts.count {
                            fractionView(opts[choice], fontSize: 34, color: .white)
                        } else {
                            Text("\(choice)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                        }
                    }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(color(for: choice, at: index))
                                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
                        )
                }
                .disabled(isAnswered)
                .scaleEffect(selected == choice ? 1.08 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
            }
        }
    }

    // A distinct shade per answer slot (used until an answer is chosen).
    private static let choiceShades: [Color] = [
        Color(red: 0.35, green: 0.55, blue: 0.95),   // blue
        Color(red: 0.55, green: 0.40, blue: 0.90),   // purple
        Color(red: 0.25, green: 0.72, blue: 0.62),   // teal
        Color(red: 0.95, green: 0.55, blue: 0.30)    // orange
    ]

    private func color(for choice: Int, at index: Int) -> Color {
        guard let selected else {
            return Self.choiceShades[index % Self.choiceShades.count]
        }
        if choice == question.answer {
            return Color.green
        }
        if choice == selected {
            return Color.red
        }
        return Color.gray.opacity(0.5)
    }

    // MARK: - Game Flow

    private func tick() {
        guard phase == .playing else { return }
        timeRemaining -= Self.tickInterval
        if !isAnswered {
            questionElapsed += Self.tickInterval
            if questionElapsed >= age.questionTimeLimit {
                handleTimeout()
            }
        }
        if timeRemaining <= 0 {
            timeRemaining = 0
            phase = .gameOver
        }
    }

    private func handleTimeout() {
        didTimeOut = true
        let penalty = -Self.wrongPenalty
        score = max(0, score + penalty)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            streak = 0
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            pointsPopup = penalty
            bonusPopup = nil
        }
        advanceAfterDelay()
    }

    private func advanceAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            guard phase == .playing else { return }
            question = Question.random(mode: mode, age: age)
            selected = nil
            didTimeOut = false
            questionElapsed = 0
            withAnimation(.easeOut(duration: 0.25)) {
                pointsPopup = nil
                bonusPopup = nil
            }
        }
    }

    private func tap(_ choice: Int) {
        guard phase == .playing, !isAnswered else { return }
        selected = choice

        let base: Int
        var bonus = 0
        if choice == question.answer {
            base = currentPoints
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                streak += 1
                correctCount += 1
            }
            if streak >= 3 {
                bonus = streak
            }
            score += base + bonus
            bestStreak = max(bestStreak, streak)
            playCorrectFeedback()
        } else {
            base = -Self.wrongPenalty
            score = max(0, score + base)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                streak = 0
            }
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            pointsPopup = base
            bonusPopup = bonus > 0 ? bonus : nil
        }

        advanceAfterDelay()
    }

    private func start(mode newMode: GameMode) {
        mode = newMode
        score = 0
        streak = 0
        bestStreak = 0
        correctCount = 0
        selected = nil
        didTimeOut = false
        timeRemaining = Self.gameDuration
        questionElapsed = 0
        pointsPopup = nil
        bonusPopup = nil
        hasSubmittedScore = false
        showQuitConfirmation = false
        newEntryID = nil
        climbRemaining = 0
        climbStarted = false
        revealAllScores = false
        iconEntryOffset = 0
        question = Question.random(mode: newMode, age: age)
        phase = .playing
    }

    private func selectAge(_ newAge: AgeGroup) {
        age = newAge
        UserDefaults.standard.set(newAge.rawValue, forKey: Self.ageGroupKey)
        phase = .selectMode
    }

    private func backToWelcome() {
        phase = .welcome
    }

    private func backToMenu() {
        phase = .selectMode
    }

    private func submitScore() {
        let trimmed = playerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameFieldFocused = true
            return
        }
        UserDefaults.standard.set(trimmed, forKey: Self.playerNameKey)
        let newID = leaderboard.add(name: trimmed, score: score, mode: mode)
        newEntryID = newID
        climbStarted = false
        revealAllScores = false
        let ranked = leaderboard.top(for: mode)
        let idx = ranked.firstIndex { $0.id == newID } ?? 0
        climbRemaining = max(0, ranked.count - 1 - idx)   // rows below = rows to climb
        hasSubmittedScore = true
        nameFieldFocused = false
        leaderboardMode = mode
        phase = .leaderboard
    }

    private func leaveLeaderboard() {
        newEntryID = nil
        climbRemaining = 0
        climbStarted = false
        revealAllScores = false
        phase = .welcome
    }

    /// Climb one row at a time, pausing 100 ms after each lower score is passed.
    /// Once the climb settles, unlock every hidden score after a 1 s beat.
    private func stepClimb() {
        guard climbRemaining > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    revealAllScores = true
                }
            }
            return
        }
        withAnimation(.easeInOut(duration: 0.18)) {
            climbRemaining -= 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18 + 0.10) {
            stepClimb()
        }
    }

    private func playCorrectFeedback() {
        guard !focusMode else { return }
        AudioServicesPlaySystemSound(1057)
    }

    private func setFocusMode(_ on: Bool) {
        focusMode = on
        UserDefaults.standard.set(on, forKey: Self.focusModeKey)
    }
}

struct FlamePulse: ViewModifier {
    @State private var pulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pulsing ? 1.15 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}

#Preview {
    ContentView()
}
