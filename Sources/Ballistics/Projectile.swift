import Foundation

struct Ammunition {
    let projectile: Projectile
    let muzzleVelocity: Measurement<UnitSpeed>
}

struct Projectile {
    let bc: BallisticCoefficient
    let weight: Measurement<UnitMass>
    let hasDimensions: Bool
    let diameter: Measurement<UnitLength>
    let length: Measurement<UnitLength>

    var ballisticCoefficient: Double {
        if bc.kind == .ballisticCoefficient {
            return bc.value
        }
        return weight.converted(to: .grains).value / 7000.0 / pow(diameter.converted(to: .inches).value, 2) / bc.value
    }

    init(bc: BallisticCoefficient, weight: Measurement<UnitMass>) {
        self.bc = bc
        self.weight = weight
        self.hasDimensions = false
        self.diameter = Measurement(value: 0, unit: .inches)
        self.length = Measurement(value: 0, unit: .inches)
    }

    init(bc: BallisticCoefficient, weight: Measurement<UnitMass>, diameter: Measurement<UnitLength>, length: Measurement<UnitLength>) {
        self.bc = bc
        self.weight = weight
        self.hasDimensions = true
        self.diameter = diameter
        self.length = length
    }

    
}

