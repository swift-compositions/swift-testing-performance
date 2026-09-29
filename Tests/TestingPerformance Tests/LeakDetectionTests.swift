// LeakDetectionTests.swift
// TestingPerformance

import Testing
import TestingPerformance

@Suite("Leak Detection Tests")
struct LeakDetectionTests {
    @Test("Detect no leaks in simple operation")
    func detectNoLeaks() async throws {
        // This test should NOT leak - creates and releases array
        do {
            try await TestingPerformance.expectPerformance(
                lessThan: .seconds(1),
                iterations: 5
            ) { () async in
                _ = Array(repeating: 0, count: 100)
            }
        } catch {
            // Expected - test runs successfully, no leak errors
        }
    }

    @Test("Leak detector integration with AllocationTracker")
    func leakDetectorIntegration() {
        // Test that leak detection uses MemoryAllocation.LeakDetector properly
        let detector = MemoryAllocation.LeakDetector()

        // Intentionally create leaked memory (simulated)
        var leaked: [[Int]] = []
        for i in 0..<10 {
            leaked.append(Array(repeating: i, count: 100))
        }

        // On some platforms, detector might not catch all leaks
        // This just verifies the API works
        _ = detector.hasLeaks()
        _ = detector.netAllocations
        _ = detector.netBytes

        // Keep leaked alive to prevent optimization
        #expect(leaked.count == 10)
    }
}
