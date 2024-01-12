import Foundation

//ShotParameters struct keeps parameters of the shot to be calculated
struct ShotParameters {
    let sightAngle: Measurement<UnitAngle>
    let shotAngle: Measurement<UnitAngle>
    let cantAngle: Measurement<UnitAngle>
    let maximumDistance: Measurement<UnitLength>
    let step: Measurement<UnitLength>

    init(sightAngle: Measurement<UnitAngle>, maximumDistance: Measurement<UnitLength>, step: Measurement<UnitLength>) {
        self.sightAngle = sightAngle
        self.shotAngle = .init(value: 0, unit: .radians)
        self.cantAngle = .init(value: 0, unit: .radians)
        self.maximumDistance = maximumDistance
        self.step = step
    }

    init(sightAngle: Measurement<UnitAngle>, shotAngle: Measurement<UnitAngle>, cantAngle: Measurement<UnitAngle>, maximumDistance: Measurement<UnitLength>, step: Measurement<UnitLength>) {
        self.sightAngle = sightAngle
        self.shotAngle = shotAngle
        self.cantAngle = cantAngle
        self.maximumDistance = maximumDistance
        self.step = step
    }
}

