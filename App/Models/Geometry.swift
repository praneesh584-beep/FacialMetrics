import Foundation
import simd

struct Vector2: Codable, Equatable, Sendable {
    var x: Double
    var y: Double
}

struct Vector3: Codable, Equatable, Sendable {
    var x: Double
    var y: Double
    var z: Double

    static let zero = Vector3(x: 0, y: 0, z: 0)

    func distance(to other: Vector3) -> Double {
        let dx = x - other.x
        let dy = y - other.y
        let dz = z - other.z
        return (dx * dx + dy * dy + dz * dz).squareRoot()
    }
}

struct Matrix4x4Snapshot: Codable, Equatable, Sendable {
    var values: [Double]

    static let identity = Matrix4x4Snapshot(values: [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    ])

    init(values: [Double]) {
        precondition(values.count == 16, "Matrix4x4Snapshot requires 16 values")
        self.values = values
    }

    init(_ matrix: simd_float4x4) {
        values = [
            Double(matrix.columns.0.x), Double(matrix.columns.0.y), Double(matrix.columns.0.z), Double(matrix.columns.0.w),
            Double(matrix.columns.1.x), Double(matrix.columns.1.y), Double(matrix.columns.1.z), Double(matrix.columns.1.w),
            Double(matrix.columns.2.x), Double(matrix.columns.2.y), Double(matrix.columns.2.z), Double(matrix.columns.2.w),
            Double(matrix.columns.3.x), Double(matrix.columns.3.y), Double(matrix.columns.3.z), Double(matrix.columns.3.w)
        ]
    }

    var translation: Vector3 {
        Vector3(x: values[12], y: values[13], z: values[14])
    }
}

enum AngleMath {
    static func normalizedRadians(_ angle: Double) -> Double {
        var value = angle
        while value > .pi { value -= 2 * .pi }
        while value < -.pi { value += 2 * .pi }
        return value
    }

    static func degrees(fromRadians radians: Double) -> Double {
        radians * 180 / .pi
    }
}

enum RobustStats {
    static func median(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    static func trimmedMean(_ values: [Double], trimFraction: Double = 0.1) -> Double? {
        guard !values.isEmpty else { return nil }
        let clamped = min(max(trimFraction, 0), 0.45)
        let sorted = values.sorted()
        let trimCount = Int(Double(sorted.count) * clamped)
        let kept = Array(sorted.dropFirst(trimCount).dropLast(trimCount))
        guard !kept.isEmpty else { return median(values) }
        return kept.reduce(0, +) / Double(kept.count)
    }
}
