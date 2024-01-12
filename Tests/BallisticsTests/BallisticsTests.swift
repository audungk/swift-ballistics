import XCTest
@testable import Ballistics

final class BallisticCalculatorTests: XCTestCase {

    func testZero1() {
        let bc = BallisticCoefficient(0.365, dragModel: .g1)
        let projectile = Projectile(bc: bc, weight: Measurement(value: 69, unit: .grains))
        let ammo = Ammunition(projectile: projectile, muzzleVelocity: Measurement(value: 2600, unit: .feetPerSecond))

        let zero = ZeroInfo(distance: .init(value: 100, unit: .yards))

        let weapon = Weapon(sightHeight: .init(value: 3.2, unit: .inches), zeroInfo: zero)
        let atmosphere = Atmosphere.standard

        let calculator = BallisticCalulator()

        let sightAngle = calculator.sightAngle(ammunition: ammo, weapon: weapon, atmosphere: atmosphere)

        XCTAssertEqual(
            sightAngle.converted(to: .radians).value, 0.001651, accuracy: 1e-6,
            "TestZero1 failed \(sightAngle.converted(to: .radians).value)"
        )
    }
    

    func testZero2() {
        let bc = BallisticCoefficient(0.223, dragModel: .g7)
        let projectile = Projectile(bc: bc, weight: .init(value: 168, unit: .grains))
        let ammo = Ammunition(projectile: projectile, muzzleVelocity: .init(value: 2750, unit: .feetPerSecond))
        let zero = ZeroInfo(distance: .init(value: 100, unit: .yards))

        let weapon = Weapon(sightHeight: .init(value: 2, unit: .inches), zeroInfo: zero)
        let atmosphere = Atmosphere.standard

        let calculator = BallisticCalulator()
        let sightAngle = calculator.sightAngle(ammunition: ammo, weapon: weapon, atmosphere: atmosphere)

        XCTAssertEqual(
            sightAngle.converted(to: .radians).value, 0.001228, accuracy: 1e-6,
            "TestZero1 failed \(sightAngle.converted(to: .radians).value)"
        )
    }

    func testPathG1() {
        let bc = BallisticCoefficient(0.223, dragModel: .g1)
        let projectile = Projectile(bc: bc, weight: .init(value: 168, unit: .grains))
        let ammo = Ammunition(projectile: projectile, muzzleVelocity: .init(value: 2750, unit: .feetPerSecond))

        let zero = ZeroInfo(distance: .init(value: 100, unit: .yards))
        let weapon = Weapon(sightHeight: .init(value: 2, unit: .inches), zeroInfo: zero)

        let atmosphere = Atmosphere.standard
        
        let shotInfo = ShotParameters(
            sightAngle: .init(value: 0.001228, unit: .radians),
            maximumDistance: .init(value: 1000, unit: .yards),
            step: .init(value: 100, unit: .yards)
        )

        let wind = WindInfo(
            velocity: .init(value: 5, unit: .milesPerHour),
            direction: .init(value: -45, unit: .degrees)
        )

        let calculator = BallisticCalulator()
        let data = calculator.trajectory(ammunition: ammo, weapon: weapon, atmosphere: atmosphere, shotInfo: shotInfo, windInfo: [wind])

        XCTAssertEqual(Double(data.count), 11, accuracy:  0.1)

        validateOneImperial(data: data[0], distance: 0, velocity: 2750, mach: 2.463, energy: 2820.6, path: -2, hold: 0, windage: 0, windAdjustment: 0, time: 0, ogv: 880, unit: .moa)
        validateOneImperial(data: data[1], distance: 100, velocity: 2351.2, mach: 2.106, energy: 2061, path: 0, hold: 0, windage: -0.6, windAdjustment: -0.6, time: 0.118, ogv: 550, unit: .moa)
        validateOneImperial(data: data[5], distance: 500, velocity: 1169.1, mach: 1.047, energy: 509.8, path: -87.9, hold: -16.8, windage: -19.5, windAdjustment: -3.7, time: 0.857, ogv: 67, unit: .moa)
        validateOneImperial(data: data[10], distance: 1000, velocity: 776.4, mach: 0.695, energy: 224.9, path: -823.9, hold: -78.7, windage: -87.5, windAdjustment: -8.4, time: 2.495, ogv: 20, unit: .moa)
       }

        func testPathG7() {

            let bc = BallisticCoefficient(0.223, dragModel: .g7)
            let projectile = Projectile(bc: bc, weight: .init(value: 168, unit: .grains), diameter: .init(value: 0.308, unit: .inches), length: .init(value: 1.282, unit: .inches))
            let ammo = Ammunition(projectile: projectile, muzzleVelocity: .init(value: 2750, unit: .feetPerSecond))

            let zero = ZeroInfo(distance: .init(value: 100, unit: .yards))

            let twist = Twist(direction: .right, rate: .init(value: 11.24, unit: .inches))

            let weapon = Weapon(sightHeight: .init(value: 2, unit: .inches), zeroInfo: zero, twist: twist)
            let atmosphere = Atmosphere.standard

            let shotInfo = ShotParameters(
                sightAngle: .init(value: 4.221, unit: .moa),
                maximumDistance: .init(value: 1000, unit: .yards),
                step: .init(value: 100, unit: .yards)
            )

            let wind = WindInfo(
                velocity: .init(value: 5, unit: .milesPerHour),
                direction: .init(value: -45, unit: .degrees)
            )

            let calculator = BallisticCalulator()
            let data = calculator.trajectory(ammunition: ammo, weapon: weapon, atmosphere: atmosphere, shotInfo: shotInfo, windInfo: [wind])

            XCTAssertEqual(Double(data.count), 11, accuracy: 0.1, "Length")

            validateOneImperial(data: data[0], distance: 0, velocity: 2750, mach: 2.463, energy: 2820.6, path: -2, hold: 0, windage: 0, windAdjustment: 0, time: 0, ogv: 880, unit: .mil)
            validateOneImperial(data: data[1], distance: 100, velocity: 2544.3, mach: 2.279, energy: 2416, path: 0, hold: 0, windage: -0.35, windAdjustment: -0.09, time: 0.113, ogv: 698, unit: .mil)
            validateOneImperial(data: data[5], distance: 500, velocity: 1810.7, mach: 1.622, energy: 1226, path: -56.3, hold: -3.18, windage: -6.16, windAdjustment: -0.55, time: 0.673, ogv: 252, unit: .mil)
            validateOneImperial(data: data[10], distance: 1000, velocity: 1081.3, mach: 0.968, energy: 442, path: -401.6, hold: -11.32, windage: -30.91, windAdjustment: -0.8747, time: 1.748, ogv: 55, unit: .mil)
        }
        
        func testAmmunitionReturnBC() {
            let bc = BallisticCoefficient(0.223, dragModel: .g7)
            let projectile = Projectile(bc: bc, weight: .init(value: 69, unit: .grains))

            XCTAssertEqual(bc.value, 0.223, accuracy: 0.0005)
            XCTAssertEqual(projectile.ballisticCoefficient, 0.223, accuracy: 0.0005)
        }
    //
    //    func TestAmmunictionReturnFF(t *testing.T) {
    //        bc, _ := externalballistics.CreateBallisticCoefficientForCustomDragFunction(1.184, externalballistics.FF,
    //            func(mach float64) float64 {
    //                return 0
    //            })
    //        var projectile = externalballistics.CreateProjectileWithDimensions(bc, unit.MustCreateDistance(0.204, unit.DistanceInch), unit.MustCreateDistance(1, unit.DistanceInch), unit.MustCreateWeight(40, unit.WeightGrain))
    //        assertEqual(t, bc.Value(), 1.184, 0.0005, "ff")
    //        assertEqual(t, projectile.GetBallisticCoefficient(), 0.116, 0.0005, "BC Calculated")
    //    }

    func validateOneImperial(data: TrajectoryData, distance: Double, velocity: Double, mach: Double, energy: Double, path: Double, hold: Double, windage: Double, windAdjustment: Double, time: Double, ogv: Double, unit: UnitAngle) {

        XCTAssertEqual(distance, data.travelDistance.converted(to: .yards).value, accuracy: 0.001)
        XCTAssertEqual(velocity, data.velocity.converted(to: .feetPerSecond).value, accuracy: 5, "Velocity")
        XCTAssertEqual(mach, data.mach, accuracy: 0.005)
        XCTAssertEqual(energy, data.energy.converted(to: .footPounds).value, accuracy: 5, "Energy")
        XCTAssertEqual(time, data.time.converted(to: .seconds).value, accuracy: 0.06, "Time")
        XCTAssertEqual(ogv, data.optimalGameWeight.converted(to: .pounds).value, accuracy: 1, "OGV")

        if distance >= 800 {
            XCTAssertEqual(path, data.drop.converted(to: .inches).value, accuracy: 4)
        } else if distance >= 500 {
            XCTAssertEqual(path, data.drop.converted(to: .inches).value, accuracy: 1)
        } else {
            XCTAssertEqual(path, data.drop.converted(to: .inches).value, accuracy: 0.5)
        }

        if distance > 1 {
            XCTAssertEqual(hold, data.dropAdjustment.converted(to: unit).value, accuracy: 0.5, "Drop")
        }

        if distance >= 800 {
            XCTAssertEqual(windage, data.windage.converted(to: .inches).value, accuracy: 1.5)
        } else if distance >= 500 {
            XCTAssertEqual(windage, data.windage.converted(to: .inches).value, accuracy: 1)
        } else {
            XCTAssertEqual(windage, data.windage.converted(to: .inches).value, accuracy: 0.5)
        }

        if distance > 1 {
            XCTAssertEqual(windAdjustment, data.windageAdjustment.converted(to: unit).value, accuracy: 0.5, "WAdj")
        }
    }

    func validateOneMetric(data: TrajectoryData, distance: Double, drop: Double, velocity: Double, time: Double) {
        XCTAssertEqual(distance, data.travelDistance.converted(to: .meters).value, accuracy: 0.1, "Distance")
    //be accurate within 1/3 of moa
        let vac = Measurement<UnitAngle>(value: 0.3, unit: .moa).converted(to: .cmPer100m).value * distance / 100

        XCTAssertEqual(drop, data.drop.converted(to: .centimeters).value, accuracy: vac, "Drop")
        XCTAssertEqual(velocity, data.velocity.converted(to: .metersPerSecond).value, accuracy: 5, "Velocity")
        XCTAssertEqual(time, data.time.converted(to: .seconds).value, accuracy: 0.05, "Time")
    }

    /** 
     var customTable = []externalballistics.DataPoint{
     {B: 0.119, A: 0},
     {B: 0.119, A: 0.7},
     {B: 0.12, A: 0.85},
     {B: 0.122, A: 0.87},
     {B: 0.126, A: 0.9},
     {B: 0.148, A: 0.93},
     {B: 0.182, A: 0.95},
     }

     var customCurve = externalballistics.CalculateCurve(customTable)

     func customDragFunction(mach float64) float64 {
     return externalballistics.CalculateByCurve(customTable, customCurve, mach)
     }

     func TestCustomCurve(t *testing.T) {
     bc, _ := externalballistics.CreateBallisticCoefficientForCustomDragFunction(1, externalballistics.FF, customDragFunction)
     var projectile = externalballistics.CreateProjectileWithDimensions(bc, unit.MustCreateDistance(119.56, unit.DistanceMillimeter), unit.MustCreateDistance(20, unit.DistanceInch), unit.MustCreateWeight(13585, unit.WeightGram))
     var ammo = externalballistics.CreateAmmunition(projectile, unit.MustCreateVelocity(555, unit.VelocityMPS))
     var zero = externalballistics.CreateZeroInfo(unit.MustCreateDistance(100, unit.DistanceMeter))
     var weapon = externalballistics.CreateWeapon(unit.MustCreateDistance(40, unit.DistanceMillimeter), zero)
     var atmosphere = externalballistics.CreateDefaultAtmosphere()

     var calc = externalballistics.CreateTrajectoryCalculator()
     var sightAngle = calc.SightAngle(ammo, weapon, atmosphere)
     var shotInfo = externalballistics.CreateShotParameters(sightAngle, unit.MustCreateDistance(1500, unit.DistanceMeter), unit.MustCreateDistance(100, unit.DistanceMeter))
     var data = calc.Trajectory(ammo, weapon, atmosphere, shotInfo, nil)
     validateOneMetric(t, data[1], 100, 0, 550, 0.182)
     validateOneMetric(t, data[2], 200, -28.4, 544, 0.364)
     validateOneMetric(t, data[15], 1500, -3627.8, 486, 2.892)
     }

     */
}
