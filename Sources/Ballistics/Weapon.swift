import Foundation

struct Twist {

    enum Direction: Int, Codable, CustomStringConvertible {
        case left
        case right

        var description: String {
            switch self {
            case .left:
                return "Left"
            case .right:
                return "Right"
            }
        }
    }

    let direction: Twist.Direction
    let rate: Measurement<UnitLength>
}


struct ZeroInfo {
    let ammunition: Ammunition?
    let distance: Measurement<UnitLength>
    let atmosphere: Atmosphere?

    init(distance: Measurement<UnitLength>) {
        self.ammunition = nil
        self.distance = distance
        self.atmosphere = nil
    }

    init(distance: Measurement<UnitLength>, atmosphere: Atmosphere) {
        self.ammunition = nil
        self.distance = distance
        self.atmosphere = atmosphere

    }

    init(distance: Measurement<UnitLength>, ammunition: Ammunition) {
        self.ammunition = ammunition
        self.distance = distance
        self.atmosphere = nil
    }

    init(distance: Measurement<UnitLength>, ammunition: Ammunition, atmosphere: Atmosphere) {
        self.distance = distance
        self.atmosphere = atmosphere
        self.ammunition = ammunition
    }

}


struct Weapon {
    let sightHeight: Measurement<UnitLength>
    let zeroInfo: ZeroInfo
    let twist: Twist?
    let clickValue: Measurement<UnitAngle>

    init(sightHeight: Measurement<UnitLength>, zeroInfo: ZeroInfo, twist: Twist?, clickValue: Measurement<UnitAngle>) {
        self.sightHeight = sightHeight
        self.zeroInfo = zeroInfo
        self.twist = twist
        self.clickValue = clickValue
    }

    init(sightHeight: Measurement<UnitLength>, zeroInfo: ZeroInfo) {
        self.sightHeight = sightHeight
        self.zeroInfo = zeroInfo
        self.twist = nil
        self.clickValue = Measurement(value: 0.1, unit: .mil)
    }

    init(sightHeight: Measurement<UnitLength>, zeroInfo: ZeroInfo, twist: Twist) {
        self.sightHeight = sightHeight
        self.zeroInfo = zeroInfo
        self.twist = twist
        self.clickValue = Measurement(value: 0.1, unit: .mil)
    }
}
