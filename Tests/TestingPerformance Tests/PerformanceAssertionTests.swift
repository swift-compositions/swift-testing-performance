// PerformanceAssertionTests.swift
// TestingPerformance
//
// Performance assertion API tests

import Testing
import TestingPerformance

extension PerformanceTests {
    @Suite(.serialized)
    struct PerformanceAssertions {

        @Test
        func `expectPerformance with passing threshold`() throws {
            let (result, measurement) = try TestingPerformance.expectPerformance(
                lessThan: .milliseconds(100),
                iterations: 10
            ) {
                let numbers = Array(1...5_000)
                return numbers.reduce(0, +)
            }

            #expect(result > 0)
            #expect(measurement.median < .milliseconds(100))
        }

        @Test
        func `expectPerformance with custom metric`() throws {
            let (_, measurement) = try TestingPerformance.expectPerformance(
                lessThan: .milliseconds(100),
                iterations: 10,
                metric: .p95
            ) {
                let numbers = Array(1...5_000)
                return numbers.reduce(0, +)
            }

            #expect(measurement.p95 < .milliseconds(100))
        }

        @Test
        func `expectNoRegression with improvement`() throws {
            let baseline = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(10), count: 10)
            )

            let current = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(8), count: 10)
            )

            // Should not throw - performance improved
            try TestingPerformance.expectNoRegression(
                current: current,
                baseline: baseline,
                tolerance: 0.10
            )
        }

        @Test
        func `expectNoRegression within tolerance`() throws {
            let baseline = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(10), count: 10)
            )

            let current = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(10.5), count: 10)
            )

            // 5% regression, within 10% tolerance
            try TestingPerformance.expectNoRegression(
                current: current,
                baseline: baseline,
                tolerance: 0.10
            )
        }

        @Test
        func `expectPerformance throws when threshold exceeded`() {
            #expect(throws: TestingPerformance.Error.self) {
                try TestingPerformance.expectPerformance(
                    lessThan: .nanoseconds(1),  // Impossibly fast threshold
                    iterations: 5
                ) {
                    let numbers = Array(1...10_000)
                    return numbers.reduce(0, +)
                }
            }
        }

        @Test
        func `expectPerformance async throws when threshold exceeded`() async {
            await #expect(throws: TestingPerformance.Error.self) {
                try await TestingPerformance.expectPerformance(
                    lessThan: .nanoseconds(1),  // Impossibly fast threshold
                    iterations: 5
                ) { () async -> Int in
                    let numbers = Array(1...10_000)
                    return numbers.reduce(0, +)
                }
            }
        }

        @Test
        func `expectNoRegression throws when regression exceeds tolerance`() {
            let baseline = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(10), count: 10)
            )

            let current = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(20), count: 10)
            )

            // 100% regression, exceeds 10% tolerance
            #expect(throws: TestingPerformance.Error.self) {
                try TestingPerformance.expectNoRegression(
                    current: current,
                    baseline: baseline,
                    tolerance: 0.10
                )
            }
        }

        @Test
        func `expectPerformance error contains metric information`() {
            do {
                try TestingPerformance.expectPerformance(
                    lessThan: .nanoseconds(1),
                    iterations: 5,
                    metric: .p95
                ) {
                    let numbers = Array(1...10_000)
                    return numbers.reduce(0, +)
                }
                Issue.record("Expected error to be thrown")
            } catch let error as TestingPerformance.Error {
                let description = error.description
                #expect(description.contains("p95"))
                #expect(description.contains("Performance expectation failed"))
            } catch {
                Issue.record("Expected TestingPerformance.Error, got \(error)")
            }
        }

        @Test
        func `expectNoRegression error contains regression percentage`() {
            let baseline = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(10), count: 10)
            )

            let current = TestingPerformance.Measurement(
                durations: Array(repeating: .milliseconds(15), count: 10)
            )

            do {
                try TestingPerformance.expectNoRegression(
                    current: current,
                    baseline: baseline,
                    tolerance: 0.10,
                    metric: .median
                )
                Issue.record("Expected error to be thrown")
            } catch let error as TestingPerformance.Error {
                let description = error.description
                #expect(description.contains("median"))
                #expect(description.contains("Regression"))
                #expect(description.contains("%"))
            } catch {
                Issue.record("Expected TestingPerformance.Error, got \(error)")
            }
        }
    }
}
