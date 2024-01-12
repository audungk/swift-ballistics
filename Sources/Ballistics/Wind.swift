import Foundation

//WindInfo structure keeps information about wind
struct WindInfo {

    //UntilDistance returns the distance from the shooter until which the wind blows
    let untilDistance: Measurement<UnitLength>

    //Velocity returns the wind velocity
    let velocity: Measurement<UnitSpeed>

    //Direction returns the wind direction.
    //
    //0 degrees means wind blowing into the face
    //90 degrees means wind blowing from the left
    //-90 or 270 degrees means wind blowing from the right
    //180 degrees means wind blowing from the back

    let direction: Measurement<UnitAngle>

    init(velocity: Measurement<UnitSpeed>, direction: Measurement<UnitAngle>) {
        self.untilDistance = .init(value: 9999, unit: .kilometers)
        self.velocity = velocity
        self.direction = direction
    }
}
