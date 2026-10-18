#!/usr/bin/env swift
// generate-simulated-run.swift
// Builds sandbox/Resources/Datasets/simulated-run.csv: the synthetic 50-minute
// first run built to show every stage of TrueEffortScore, sampled every 5 seconds.
//
// The run matches the TES animated explainer moment for moment, and Quiver's
// TrueEffortScore scores it as a first run at raw 58.4, adjusted 81.7.
//
// Usage: swift Scripts/generate-simulated-run.swift sandbox/Resources/Datasets/simulated-run.csv

import Foundation

/// The explainer's 32-bit seeded generator (mulberry32), seed 7.
struct Mulberry32 {
    var state: UInt32

    /// Returns the next uniform value in [0, 1).
    mutating func nextUniform() -> Double {
        state = state &+ 0x6D2B_79F5
        var t = (state ^ (state >> 15)) &* (1 | state)
        t = (t &+ ((t ^ (t >> 7)) &* (61 | t))) ^ t
        return Double(t ^ (t >> 14)) / 4_294_967_296
    }

    /// Returns roughly normal noise in about [-1, 1] from three uniform draws.
    mutating func nextNoise() -> Double {
        (nextUniform() + nextUniform() + nextUniform() - 1.5) / 1.5
    }
}

/// Target heart rate, pace (min/km), cadence (spm), and vertical oscillation (cm) for one movement.
struct Movement {
    let heartRate: Double
    let pace: Double
    let cadence: Double
    let verticalOscillation: Double
}

/// One stretch of the run: start and end minute, movement, and target grade in percent.
struct Segment {
    let start: Double
    let end: Double
    let movement: Movement
    let grade: Double
}

let easy = Movement(heartRate: 134, pace: 6.5, cadence: 165, verticalOscillation: 8.6)
let tempo = Movement(heartRate: 150, pace: 5.6, cadence: 171, verticalOscillation: 8.1)
let threshold = Movement(heartRate: 160, pace: 5.1, cadence: 176, verticalOscillation: 7.6)
let climb = Movement(heartRate: 173, pace: 5.9, cadence: 177, verticalOscillation: 7.3)
let descent = Movement(heartRate: 131, pace: 5.1, cadence: 157, verticalOscillation: 10.9)
let stride = Movement(heartRate: 176, pace: 4.3, cadence: 184, verticalOscillation: 6.6)
let walk = Movement(heartRate: 118, pace: 11, cadence: 112, verticalOscillation: 8.0)

var plan: [Segment] = [
    Segment(start: 0, end: 6, movement: easy, grade: 0),
    Segment(start: 6, end: 13, movement: tempo, grade: 0.5),
    Segment(start: 13, end: 16.5, movement: climb, grade: 5.5),
    Segment(start: 16.5, end: 18.5, movement: descent, grade: -5.8),
    Segment(start: 18.5, end: 22, movement: easy, grade: 0),
    Segment(start: 22, end: 28, movement: threshold, grade: 0.5),
    Segment(start: 28, end: 31, movement: climb, grade: 6),
    Segment(start: 31, end: 33, movement: descent, grade: -6),
    Segment(start: 33, end: 36, movement: easy, grade: 0),
    Segment(start: 36, end: 40, movement: tempo, grade: 0.5)
]
for k in 0..<4 {
    let start = 40 + Double(k)
    plan.append(Segment(start: start, end: start + 1.0 / 3.0, movement: stride, grade: 0))
    plan.append(Segment(start: start + 1.0 / 3.0, end: start + 1, movement: easy, grade: 0))
}
plan.append(Segment(start: 44, end: 47, movement: easy, grade: 0))
plan.append(Segment(start: 47, end: 50, movement: walk, grade: 0))

/// Returns the segment that covers the given minute, or the last segment past the end.
func segment(at minute: Double) -> Segment {
    for candidate in plan where minute >= candidate.start && minute < candidate.end {
        return candidate
    }
    return plan[plan.count - 1]
}

guard CommandLine.arguments.count == 2 else {
    print("usage: swift Scripts/generate-simulated-run.swift <output.csv>")
    exit(1)
}

let sampleInterval = 5.0
let sampleCount = 600   // 50 minutes every 5 seconds

var rng = Mulberry32(state: 7)
var heartRate = 118.0, grade = 0.0, verticalOscillation = 8.6, pace = 6.5, cadence = 165.0, altitude = 100.0
var lines = ["time,heartRate,pace,cadence,grade,verticalOscillation,altitude"]

for i in 0..<sampleCount {
    let target = segment(at: Double(i) * sampleInterval / 60)
    let movement = target.movement

    // Each signal eases toward its target; the draw order matches the explainer.
    grade += (target.grade - grade) * 0.35 + rng.nextNoise() * 0.2
    heartRate += (movement.heartRate + Swift.max(0, grade) * 0.5 - heartRate) * 0.12 + rng.nextNoise() * 1
    pace += (movement.pace - pace) * 0.5
    cadence += (movement.cadence - cadence) * 0.6
    verticalOscillation += (movement.verticalOscillation - verticalOscillation) * 0.4

    let samplePace = pace + rng.nextNoise() * 0.06
    let sampleCadence = cadence + rng.nextNoise() * 1.2
    let sampleOscillation = verticalOscillation + rng.nextNoise() * 0.05

    // Altitude follows the distance covered at this grade; the first sample stays at 100 m.
    if i > 0 {
        altitude += 1000 / (60 * samplePace) * sampleInterval * grade / 100
    }

    let fields = [heartRate, samplePace, sampleCadence, grade, sampleOscillation, altitude]
        .map { String(format: "%.4f", $0) }
    lines.append(([String(i * Int(sampleInterval))] + fields).joined(separator: ","))
}

do {
    try (lines.joined(separator: "\r\n") + "\r\n")
        .write(toFile: CommandLine.arguments[1], atomically: true, encoding: .utf8)
    print("wrote \(sampleCount) rows to \(CommandLine.arguments[1])")
} catch {
    print("could not write \(CommandLine.arguments[1]): \(error)")
    exit(1)
}
