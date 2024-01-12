import Foundation

class CustomAngleConverter: UnitConverter {

    override func baseUnitValue(fromValue value: Double) -> Double {
        let radians = tan(value / 10000)
        return radians * 180 / Double.pi
    }

    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        let radians = baseUnitValue / 180 * Double.pi
        return tan(radians) * 10000
    }
}
