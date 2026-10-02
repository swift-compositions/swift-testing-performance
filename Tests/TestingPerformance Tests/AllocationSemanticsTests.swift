import Testing
import TestingPerformance

@Suite(.serialized)
struct `Allocation Semantics` {
    static let elementCount = 8_000_000
    static let arrayBytes = elementCount * MemoryLayout<Int>.stride

    @Test
    func `an allocation freed inside the measured region nets to about zero`() {
        let (count, stats) = AllocationTracker.measure {
            Array(repeating: 1, count: Self.elementCount).count
        }
        #expect(count == Self.elementCount)
        #expect(stats.bytesAllocated < Self.arrayBytes / 2)
    }

    @Test
    func `an allocation retained past the measured region counts its live bytes`() {
        var retained: [Int] = []
        let (_, stats) = AllocationTracker.measure {
            retained = Array(repeating: 1, count: Self.elementCount)
        }
        #expect(retained.count == Self.elementCount)
        #expect(stats.bytesAllocated >= Self.arrayBytes / 2)
    }

    @Test
    func `a pre-existing allocation freed inside the measured region nets negative`() {
        var existing: [Int]? = Array(repeating: 1, count: Self.elementCount)
        #expect(existing?.count == Self.elementCount)
        let (_, stats) = AllocationTracker.measure {
            existing = nil
        }
        #expect(existing == nil)
        #expect(stats.bytesAllocated <= -(Self.arrayBytes / 2))
    }
}
