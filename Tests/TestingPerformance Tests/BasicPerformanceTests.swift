// BasicPerformanceTests.swift
// TestingPerformance
//
// Basic performance measurement tests

import Testing
import TestingPerformance

extension PerformanceTests {
    @Suite(.serialized)
    struct BasicPerformance {

        // MARK: - Basic Measurement

        @Test(.timed())
        func `basic timed test`() {
            let numbers = Array(1...10_000)
            _ = numbers.reduce(0, +)
        }

        @Test(.timed(iterations: 20))
        func `custom iteration count`() {
            let numbers = Array(1...5_000)
            _ = numbers.map { $0 * 2 }
        }

        @Test(.timed(iterations: 10, warmup: 3))
        func `with warmup iterations`() {
            let numbers = Array(1...5_000)
            _ = numbers.filter { $0 % 2 == 0 }
        }

        // MARK: - Performance Thresholds

        @Test(.timed(threshold: .milliseconds(50)))
        func `performance budget - should pass`() {
            let numbers = Array(1...10_000)
            _ = numbers.reduce(0, +)
        }

        @Test(.timed(iterations: 100, threshold: .milliseconds(1)))
        func `fast operation threshold`() {
            let numbers = Array(1...100)
            _ = numbers[50]
        }

        // MARK: - Different Metrics

        @Test(.timed(threshold: .milliseconds(50), metric: .median))
        func `median metric threshold`() {
            let numbers = Array(1...10_000)
            _ = numbers.reduce(0, +)
        }

        @Test(.timed(threshold: .milliseconds(50), metric: .mean))
        func `mean metric threshold`() {
            let numbers = Array(1...10_000)
            _ = numbers.reduce(0, +)
        }

        @Test(.timed(threshold: .milliseconds(50), metric: .p95))
        func `p95 metric threshold`() {
            let numbers = Array(1...10_000)
            _ = numbers.reduce(0, +)
        }
    }
}
