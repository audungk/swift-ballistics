import Foundation

extension UnitMass {
    static let grains = UnitMass(symbol: "gr", converter: UnitConverterLinear(coefficient: 6.479891e-5))
}

extension UnitSpeed {
    static let feetPerSecond = UnitSpeed(symbol: "fps",  converter: UnitConverterLinear(coefficient: 0.3048))
}

extension UnitAngle {
    static let milliRadians = UnitAngle(symbol: "mRad", converter: UnitConverterLinear(coefficient: 0.057296))

    static let mil = UnitAngle(symbol: "MIL", converter: UnitConverterLinear(coefficient: 0.05625))

    static let moa = UnitAngle(symbol: "MOA", converter: UnitConverterLinear(coefficient: 0.016666654061044))

    static let cmPer100m = UnitAngle(symbol: "cm/100m", converter: CustomAngleConverter())
}

extension UnitEnergy {
    static let footPounds = UnitEnergy(symbol: "ft lb", converter: UnitConverterLinear(coefficient: 0.737562149))
}
