import XCTest
import Spatial

@testable import Ballistics

final class MeasurementTests: XCTestCase {

    func testCanConvertGrain() throws {
        let grain = Measurement(value: 1, unit: UnitMass.grains)
        let gram = grain.converted(to: .grams)
        XCTAssertEqual(gram.value, 0.06479891, accuracy: 1e-6)
    }

    func testCanConvertFPS() {
        let fps = Measurement(value: 1, unit: UnitSpeed.feetPerSecond)
        let mps = fps.converted(to: .metersPerSecond)
        XCTAssert(mps.value == 0.3048)
    }

    func testCanConvertFootPounds() {
        let ftLb = Measurement(value: 1, unit: UnitEnergy.footPounds)
        let j = ftLb.converted(to: .joules)
        XCTAssert(j.value == 0.737562149)
    }

    func testCanConvertMiliradians() {
        let mRad = Measurement(value: 1, unit: UnitAngle.milliRadians)
        let degree = mRad.converted(to: .degrees)
        XCTAssert(degree.value == 0.057296)
    }

    func testCanConvertMils() {
        let mil = Measurement(value: 1, unit: UnitAngle.mil)
        let mps = mil.converted(to: .degrees)
        XCTAssert(mps.value == 0.05625)
    }

    func testCentimetersPer100M() {
        let centimeterPer100M = Measurement(value: 2, unit: UnitAngle.cmPer100m)
        let degrees = centimeterPer100M.converted(to: .degrees)
        let converted = degrees.converted(to: .cmPer100m)

        XCTAssertEqual(centimeterPer100M.value, converted.value, accuracy: 1e-7)

    }

    func testVectorMagnitude()  {
        let vector = Vector3D(x: 2600, y: 0, z: 0)
        let length = vector.length

        let magnitude = sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)

        XCTAssertEqual(length, magnitude)
    }


}
