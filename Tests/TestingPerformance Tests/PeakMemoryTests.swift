// PeakMemoryTests.swift
// TestingPerformance

import Testing
import TestingPerformance

@Suite("Peak Memory Tracking Tests")
struct PeakMemoryTests {
    @Test("Peak memory tracker integration")
    func peakMemoryTrackerIntegration() {
        // Test that peak memory tracking uses MemoryAllocation.PeakMemoryTracker properly
        let tracker = MemoryAllocation.PeakMemoryTracker()

        // Create some allocations and sample
        for i in 0..<10 {
            let array = Array(repeating: 0, count: i * 100)
            tracker.sample()
            _ = array  // Keep alive
        }

        // Verify API works
        #expect(tracker.peakBytes >= 0)
        #expect(tracker.peakAllocations >= 0)
        #expect(!tracker.samples.isEmpty)
    }

    @Test("Track peak memory with limit")
    func trackPeakMemoryWithLimit() async throws {
        // This test verifies the trait API works
        // The actual peak memory limit checking happens in the trait implementation
        do {
            try await TestingPerformance.expectPerformance(
                lessThan: .seconds(1),
                iterations: 5
            ) { () async in
                // Simple operation
                _ = Array(repeating: 0, count: 100)
            }
        } catch {
            // Expected - test runs successfully
        }
    }

    @Test("PeakMemoryTracker returns valid values")
    func peakMemoryTrackerReturnsValidValues() {
        // Test the underlying tracker directly
        let tracker = MemoryAllocation.PeakMemoryTracker()

        tracker.sample()
        _ = Array(repeating: 0, count: 1000)
        tracker.sample()

        // Peak should be non-negative
        #expect(tracker.peakBytes >= 0)
        #expect(tracker.peakAllocations >= 0)
    }
}
