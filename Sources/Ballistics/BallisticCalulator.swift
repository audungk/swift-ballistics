import Foundation
import Spatial

struct BallisticCalulator {
    let zeroFindingAccuracy: Double = 0.000005
    let minimumVelocity: Double = 50.0
    let maximumDrop: Double = -15000
    let maxIterations: Int = 10
    let gravityConstant: Double = -32.17405

    let maximumStepSize: Measurement<UnitLength>

    init() {
        self.maximumStepSize = .init(value: 1, unit: .feet)
    }

    func calculationStep(for step: Double) -> Double {
        var step = step / 2

        let maximumStep = maximumStepSize.converted(to: .feet).value

        if step > maximumStep {
            let stepOrder = Int(floor(log10(step)))
            let maximumOrder = Int(floor(log10(maximumStep)))

            step = step / pow(10, Double(stepOrder-maximumOrder+1))
        }
        return step
    }

    //SightAngle calculates the sight angle for a rifle with scope height specified and zeroed using the ammo specified at
    //the range specified and under the conditions (atmosphere) specified.
    //
    //The calculated value is to be used as sightAngle parameter of the ShotParameters structure
    func sightAngle(ammunition: Ammunition, weapon: Weapon, atmosphere: Atmosphere) -> Measurement<UnitAngle> {
        let zeroDistance = Measurement(value: 10, unit: weapon.zeroInfo.distance.unit).converted(to: .feet).value
        let calculationStep = calculationStep(for: zeroDistance)

        let mach = atmosphere.mach.converted(to: .feetPerSecond).value
        let densityFactor = atmosphere.densityFactor
        let muzzleVelocity = ammunition.muzzleVelocity.converted(to: .feetPerSecond).value

        let barrelAzimuth = 0.0
        var barrelElevation = 0.0

        var zeroFindingError = zeroFindingAccuracy * 2
        var iterationsCount: Int = 0
        let bullet = ammunition.projectile
        let ballisticFactor = 1 / bullet.ballisticCoefficient

        let gravityVector = Vector3D(x: 0, y: gravityConstant, z: 0)

        while (zeroFindingError > zeroFindingAccuracy && iterationsCount < maxIterations) {

            var velocity = muzzleVelocity
            var time = 0.0

            //x - distance towards target,
            //y - drop and
            //z - windage

            var rangeVector = Vector3D(
                x: 0.0,
                y: -weapon.sightHeight.converted(to: .feet).value,
                z: 0.0
            )

            var velocityVector = Vector3D(
                x: cos(barrelElevation) * cos(barrelAzimuth),
                y: sin(barrelElevation),
                z: cos(barrelElevation) * sin(barrelAzimuth)
            ) * velocity

            let zeroDistance = weapon.zeroInfo.distance.converted(to: .feet).value
            let maximumRange = zeroDistance + calculationStep

            while rangeVector.x <= maximumRange {
                if velocity < minimumVelocity || rangeVector.y < maximumDrop {
                    break
                }

                let deltaTime = calculationStep / velocityVector.x
                velocity = velocityVector.length

                let drag = ballisticFactor * densityFactor * velocity * bullet.bc.drag(at: (velocity/mach))

                velocityVector -= ((velocityVector * drag) - gravityVector) * deltaTime

                let deltaRangeVector = Vector3D(
                    x: calculationStep,
                    y: velocityVector.y * deltaTime,
                    z: velocityVector.z * deltaTime
                )
                rangeVector += deltaRangeVector
                velocity = velocityVector.length
                time += deltaRangeVector.length / velocity

                if abs(rangeVector.x - zeroDistance) < 0.5 * calculationStep {
                    zeroFindingError = abs(rangeVector.y)
                    barrelElevation = barrelElevation - rangeVector.y / rangeVector.x
                    break
                }
            }
            iterationsCount += 1
        }

        return Measurement<UnitAngle>(value: barrelElevation, unit: .radians)
    }

    //Trajectory calculates the trajectory with the parameters specified
    func trajectory(ammunition: Ammunition, weapon: Weapon, atmosphere: Atmosphere, shotInfo: ShotParameters, windInfo: [WindInfo]) -> [TrajectoryData] {

        var deltaRangeVector = Vector3D()
        var velocityAdjusted = Vector3D()
        var _: Double = 0
        var _: Double = 0
        var drag: Double = 0
        var deltaTime: Double = 0

        let rangeTo = shotInfo.maximumDistance.converted(to: .feet).value
        let step = shotInfo.step.converted(to: .feet).value

        let calculationStep = calculationStep(for: step)

        let bulletWeight = ammunition.projectile.weight.converted(to: .grains).value
        var stabilityCoefficient = 1.0
        var calculateDrift = false

        if weapon.twist != nil && ammunition.projectile.hasDimensions {
            stabilityCoefficient = calculateStabilityCoefficient(ammunitionInfo: ammunition, rifleInfo: weapon, atmosphere: atmosphere)
            calculateDrift = true
        }

        let rangesLength = Int(floor(rangeTo/step)) + 1
        var ranges = Array(repeating: TrajectoryData(), count: rangesLength)

        let barrelAzimuth = 0.0
        var barrelElevation = shotInfo.sightAngle.converted(to: .radians).value
        barrelElevation += shotInfo.shotAngle.converted(to: .radians).value

        let alt0 = atmosphere.altitude.converted(to: .feet).value
        var currentWind: Int = 0
        var nextWindRange = 1e7

        var windVector: Vector3D

        if windInfo.isEmpty {
            windVector = Vector3D(x: 0, y: 0, z: 0)
        } else {
            if windInfo.count > 1 {
                nextWindRange = windInfo[0].untilDistance.converted(to: .feet).value
            }
            windVector = windToVector(shot: shotInfo, wind: windInfo[0])
        }

        let muzzleVelocity = ammunition.muzzleVelocity.converted(to: .feetPerSecond).value
        let gravityVector = Vector3D(x: 0, y: gravityConstant, z: 0)
        var velocity = muzzleVelocity
        var time = 0.0

        //x - distance towards target,
        //y - drop and
        //z - windage
        var rangeVector = Vector3D(x: 0.0, y: -weapon.sightHeight.converted(to: .feet).value, z: 0)
        var velocityVector = Vector3D(
            x: cos(barrelElevation) * cos(barrelAzimuth),
            y: sin(barrelElevation),
            z: cos(barrelElevation) * sin(barrelAzimuth)
        ) * velocity

        let maximumRange = rangeTo
        var nextRangeDistance: Double = 0

        var twistCoefficient: Double = 0

        if calculateDrift {
            assert(weapon.twist != nil)
            if weapon.twist?.direction == .right {
                twistCoefficient = 1
            } else {
                twistCoefficient = -1
            }
        }

        let bullet = ammunition.projectile
        let ballisticFactor = 1 / bullet.ballisticCoefficient

        var currentItem = 0

        //run all the way down the range
        while rangeVector.x <= maximumRange + calculationStep {
            if velocity < minimumVelocity || rangeVector.y < maximumDrop {
                break
            }

            let (densityFactor, mach) = atmosphere.getDensityFactorAndMach(for: alt0 + rangeVector.y)
//            let densityFactor = atmosphere.densityFactor
//            let mach = atmosphere.mach.converted(to: .feetPerSecond).value

            if rangeVector.x >= nextWindRange {
                currentWind += 1
                windVector = windToVector(shot: shotInfo, wind: windInfo[currentWind])

                if currentWind == windInfo.count - 1 {
                    nextWindRange = 1e7
                } else {
                    nextWindRange = windInfo[currentWind].untilDistance.converted(to: .feet).value
                }
            }

            if rangeVector.x >= nextRangeDistance {
                var windage = rangeVector.z
                if calculateDrift {
                    windage += (1.25 * (stabilityCoefficient + 1.2) * pow(time, 1.83) * twistCoefficient) / 12.0
                }

                let dropAdjustment = getCorrection(distance: rangeVector.x, offset: rangeVector.y)
                let windageAdjustment = getCorrection(distance: rangeVector.x, offset: windage)

                ranges[currentItem] = TrajectoryData(
                    time:              .init(value: time, unit: .seconds),
                    travelDistance:    .init(value: rangeVector.x, unit: .feet),
                    velocity:          .init(value: velocity, unit: .feetPerSecond),
                    mach:              velocity / mach,
                    drop:              .init(value: rangeVector.y, unit: .feet),
                    dropAdjustment:    .init(value: dropAdjustment, unit: .radians),
                    windage:           .init(value: windage, unit: .feet),
                    windageAdjustment: .init(value: windageAdjustment, unit: .radians),
                    energy:            .init(value: calculateEnergy(bulletWeight: bulletWeight, velocity: velocity), unit: .footPounds),
                    optimalGameWeight: .init(value: calculateOgv(bulletWeight: bulletWeight, velocity: velocity), unit: .pounds)
                )


                nextRangeDistance += step
                currentItem += 1
                if currentItem == ranges.count {
                    break
                }
            }

            deltaTime = calculationStep / velocityVector.x
            velocityAdjusted = velocityVector - windVector
            velocity = velocityAdjusted.length
            drag = ballisticFactor * densityFactor * velocity * bullet.bc.drag(at: velocity/mach)
            velocityVector = velocityVector - ((velocityAdjusted * drag - gravityVector) * deltaTime)
            deltaRangeVector = Vector3D(x: calculationStep, y: velocityVector.y * deltaTime, z: velocityVector.z * deltaTime)
            rangeVector += deltaRangeVector
            velocity = velocityVector.length
            time = time + deltaRangeVector.length / velocity
        }
        return ranges
    }

    func calculateStabilityCoefficient(ammunitionInfo: Ammunition, rifleInfo: Weapon, atmosphere: Atmosphere) -> Double {
        guard let rifleTwist = rifleInfo.twist else { assertionFailure(); return 0.0 }
        let weight = ammunitionInfo.projectile.weight.converted(to: .grains).value
        let diameter = ammunitionInfo.projectile.diameter.converted(to: .inches).value
        let twist = rifleTwist.rate.converted(to: .inches).value / diameter
        let length = ammunitionInfo.projectile.length.converted(to: .inches).value / diameter

        let sd = 30 * weight / (pow(twist, 2) * pow(diameter, 3) * length * (1 + pow(length, 2)))
        let fv = pow(ammunitionInfo.muzzleVelocity.converted(to: .feetPerSecond).value / 2800, 1.0/3.0)

        let ft = atmosphere.temperature.converted(to: .fahrenheit).value
        let pt = atmosphere.pressure.converted(to: .inchesOfMercury).value
        let ftp = ((ft + 460) / (59 + 460)) * (29.92 / pt)

        return sd * fv * ftp
    }

    func windToVector(shot: ShotParameters, wind: WindInfo) -> Vector3D {
        let sightCosine = cos(shot.sightAngle.converted(to: .radians).value)
        let sightSine = sin(shot.sightAngle.converted(to: .radians).value)
        let cantCosine = cos(shot.cantAngle.converted(to: .radians).value)
        let cantSine = sin(shot.cantAngle.converted(to: .radians).value)
        let rangeVelocity = wind.velocity.converted(to: .feetPerSecond).value * cos(wind.direction.converted(to: .radians).value)
        let crossComponent = wind.velocity.converted(to: .feetPerSecond).value * sin(wind.direction.converted(to: .radians).value)
        let rangeFactor = -rangeVelocity * sightSine
        return Vector3D(
            x: rangeVelocity * sightCosine,
            y: rangeFactor * cantCosine + crossComponent * cantSine,
            z: crossComponent * cantCosine - rangeFactor * cantSine
        )
    }

    func getCorrection(distance: Double, offset: Double) -> Double {
        return atan(offset / distance)
    }

    func calculateEnergy(bulletWeight: Double, velocity: Double) -> Double {
        return bulletWeight * pow(velocity, 2) / 450400
    }

    func calculateOgv(bulletWeight: Double, velocity: Double) -> Double {
        return pow(bulletWeight, 2) * pow(velocity, 3) * 1.5e-12
    }
}
