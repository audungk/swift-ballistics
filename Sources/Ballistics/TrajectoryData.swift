import Foundation

//TrajectoryData structure keeps information about one point of the trajectory.
struct TrajectoryData {

    //Time return the amount of time spent since the shot moment
    let time: Measurement<UnitDuration>

    //TravelledDistance returns the distance measured between the muzzle and the projection of the current bullet position to
    //the line between the muzzle and the target
    let travelDistance: Measurement<UnitLength>

    //Velocity returns the current projectile velocity
    let velocity: Measurement<UnitSpeed>

    //MachVelocity returns the proportion between the current projectile velocity and the speed of the sound
    let mach: Double

    //Drop returns the shorted distance between the projectile and the shot line
    //
    //The positive value means the the projectile is above this line and the negative value means that the projectile
    //is below this line
    let drop: Measurement<UnitLength>

    //DropAdjustment returns the angle between the shot line and the line from the muzzle to the current projectile position
    //in the plane perpendicular to the ground
    let dropAdjustment: Measurement<UnitAngle>

    //Windage returns the distance to which the projectile is displaced by wind
    let windage: Measurement<UnitLength>

    //WindageAdjustment returns the angle between the shot line and the line from the muzzle to the current projectile position
    //in the place parallel to the ground
    let windageAdjustment: Measurement<UnitAngle>

    //Energy returns the kinetic energy of the projectile
    let energy: Measurement<UnitEnergy>

    //OptimalGameWeight returns the weight of game to which a kill shot is
    //probable with the kinetic energy that the projectile currently  have
    let optimalGameWeight: Measurement<UnitMass>

    init() {
        self.time = .init(value: 0, unit: .seconds)
        self.travelDistance = .init(value: 0, unit: .meters)
        self.velocity = .init(value: 0, unit: .feetPerSecond)
        self.mach = 0
        self.drop = .init(value: 0, unit: .centimeters)
        self.dropAdjustment = .init(value: 0, unit: .radians)
        self.windage = .init(value: 0, unit: .centimeters)
        self.windageAdjustment = .init(value: 0, unit: .milliRadians)
        self.energy = .init(value: 0, unit: .joules)
        self.optimalGameWeight = .init(value: 0, unit: .kilograms)
    }

    init(time: Measurement<UnitDuration>, travelDistance: Measurement<UnitLength>, velocity: Measurement<UnitSpeed>, mach: Double, drop: Measurement<UnitLength>, dropAdjustment: Measurement<UnitAngle>, windage: Measurement<UnitLength>, windageAdjustment: Measurement<UnitAngle>, energy: Measurement<UnitEnergy>, optimalGameWeight: Measurement<UnitMass>) {
        self.time = time
        self.travelDistance = travelDistance
        self.velocity = velocity
        self.mach = mach
        self.drop = drop
        self.dropAdjustment = dropAdjustment
        self.windage = windage
        self.windageAdjustment = windageAdjustment
        self.energy = energy
        self.optimalGameWeight = optimalGameWeight
    }
}
