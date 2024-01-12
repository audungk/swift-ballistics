//
//  Atmosphere.swift
//  BallisticCalculator
//
//  Created by Audun Kjelstrup on 11/01/2024.
//

import Foundation

struct Atmosphere {

    static let icaoStandardTemperatureR: Double = 518.67
    static let icaoFreezingPointTemperatureR: Double = 459.67
    static let temperatureGradient: Double = -3.56616e-03
    static let icaoStandardHumidity: Double = 0.0
    static let pressureExponent: Double = -5.255876
    static let speedOfSound: Double = 49.0223
    static let a0: Double = 1.24871
    static let a1: Double = 0.0988438
    static let a2: Double = 0.00152907
    static let a3: Double = -3.07031e-06
    static let a4: Double = 4.21329e-07
    static let a5: Double = 3.342e-04
    static let standardTemperature: Double = 59.0
    static let standardPressure: Double = 29.92
    static let standardDensity: Double = 0.076474

    let altitude: Measurement<UnitLength>
    let pressure: Measurement<UnitPressure>
    let temperature: Measurement<UnitTemperature>
    let humidity: Double
    let density: Double
    let mach: Measurement<UnitSpeed>
    let mach1: Double

    var densityFactor: Double {
        return density / Atmosphere.standardDensity
    }

    static var standard: Atmosphere {
        Atmosphere(
            altitude: .init(value: 0, unit: .feet),
            pressure: .init(value: 29.92, unit: .inchesOfMercury),
            temperature: .init(value: 59, unit: .fahrenheit),
            humidity: 0.78
        )
    }

    init(altitude: Measurement<UnitLength>, pressure: Measurement<UnitPressure>, temperature: Measurement<UnitTemperature>, humidity: Double) {
        self.altitude = altitude
        self.pressure = pressure
        self.temperature = temperature
        self.humidity = humidity

        let result = Atmosphere.calculate0(temperature, pressure, humidity)
        self.density = result.0
        self.mach1 = result.1
        self.mach = .init(value: mach1, unit: .feetPerSecond)
    }

    static func calculate0(_ temperature: Measurement<UnitTemperature>, _ pressure: Measurement<UnitPressure>, _ humidity: Double) -> (Double, Double) {
        let t = temperature.converted(to: .fahrenheit).value
        let p = pressure.converted(to: .inchesOfMercury).value

        let hc: Double

        if t > 0.0 {
            let et0 = a0 + t*(a1+t*(a2+t*(a3+t*a4)))
            let et = a5 * humidity * et0
            hc = (p - 0.3783*et) / standardPressure
        } else {
            hc = 1.0
        }
        let calculatedDensity = standardDensity * (icaoStandardTemperatureR / (t + icaoFreezingPointTemperatureR)) * hc
        let mach1 = sqrt(t + icaoFreezingPointTemperatureR) * speedOfSound

        return (calculatedDensity, mach1)
    }

    func getDensityFactorAndMach(for altitude: Double) -> (Double, Double) {

        let orgAltitude = self.altitude.converted(to: .feet).value

        if abs(orgAltitude - altitude) < 30 {
            let density = self.density / Atmosphere.standardDensity
            let mach = self.mach1
            return (density, mach)
        }

        let t0 = temperature.converted(to: .fahrenheit).value
        var p = pressure.converted(to: .inchesOfMercury).value

        let ta = Atmosphere.icaoStandardTemperatureR + orgAltitude * Atmosphere.temperatureGradient - Atmosphere.icaoFreezingPointTemperatureR
        let tb = Atmosphere.icaoStandardTemperatureR + altitude * Atmosphere.temperatureGradient - Atmosphere.icaoFreezingPointTemperatureR
        let t = t0 + ta - tb
        p = p * pow(t0/t, Atmosphere.pressureExponent)

        let (density, mach) = Atmosphere.calculate0(.init(value: t, unit: .fahrenheit), .init(value: p, unit: .inchesOfMercury), humidity)
        return (density / Atmosphere.standardDensity, mach)
    }
}
