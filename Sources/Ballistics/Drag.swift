import Foundation

struct DragModel {

    //DataPoint is one value of the ballistic table used in
    //table-based calculations below
    //
    //The calculation is based on original JavaScript code
    //by Alexandre Trofimov
    struct DataPoint {
        let A, B: Double
    }

    //CurvePoint is an approximation of drag to speed function curve made on the
    //base of the ballistic
    struct CurvePoint {
        let A, B, C: Double
    }

    enum Kind: Int, Codable {
        case g1
        case g7
        case custom
    }

    let kind: Kind
    let curve: [DragModel.CurvePoint]
    let dragTable: [DragModel.DataPoint]

    init(kind: DragModel.Kind, dragTable: [DragModel.DataPoint] = []) {
        self.kind = kind

        switch kind {
        case .g1:
            self.dragTable = DragModel.g1
        case .g7:
            self.dragTable = DragModel.g7
        case .custom:
            self.dragTable = dragTable
        }
        self.curve = DragModel.curve(for: kind, dragTable: self.dragTable)

    }

    static func curve(for kind: DragModel.Kind, dragTable: [DragModel.DataPoint]) -> [DragModel.CurvePoint] {

        var curve = Array(repeating: CurvePoint(A: 0, B: 0, C: 0), count: dragTable.count)

        let rate = (dragTable[1].B - dragTable[0].B) / (dragTable[1].A - dragTable[0].A)
        curve[0] = CurvePoint(A: 0, B: rate, C: dragTable[0].B - dragTable[0].A * rate)

        for i in 1..<dragTable.count-1 {

            // rest as 2nd degree polynomials on three adjacent points
                let x1 = dragTable[i-1].A
                let x2 = dragTable[i].A
                let x3 = dragTable[i+1].A
                let y1 = dragTable[i-1].B
                let y2 = dragTable[i].B
                let y3 = dragTable[i+1].B

                let aNumerator = ((y3-y1)*(x2-x1) - (y2-y1)*(x3-x1))
                let aDenominator = ((x3*x3-x1*x1)*(x2-x1) - (x2*x2-x1*x1)*(x3-x1))
                let a = aNumerator / aDenominator

                let b = (y2 - y1 - a * (x2 * x2 - x1 * x1)) / (x2 - x1)
                let c = y1 - (a * x1 * x1 + b * x1)
                curve[i] = CurvePoint(A: a, B: b, C: c)
            }
        curve[dragTable.count-1] = CurvePoint(A: 0, B: 0, C: dragTable[dragTable.count-1].B)
        return curve
    }

    func drag(at mach: Double) -> Double {

        var mlo = 0
        var mhi = curve.count - 1
        var m: Int
        while (mhi - mlo) > 1 {
            let mid = Int(floor(Double(mhi+mlo) / 2.0))
            if dragTable[mid].A < mach {
                mlo = mid
            } else {
                mhi = mid
            }
        }

        if (dragTable[mhi].A - mach) > (mach - dragTable[mlo].A) {
            m = mlo
        } else {
            m = mhi
        }

        let drag = curve[m].C + mach * (curve[m].B + curve[m].A * mach)
        return drag
    }

}

extension DragModel {
    
    static var g1: [DragModel.DataPoint] {
        return  [
            DataPoint(A: 0.00, B: 0.2629),
            DataPoint(A: 0.05, B: 0.2558),
            DataPoint(A: 0.10, B: 0.2487),
            DataPoint(A: 0.15, B: 0.2413),
            DataPoint(A: 0.20, B: 0.2344),
            DataPoint(A: 0.25, B: 0.2278),
            DataPoint(A: 0.30, B: 0.2214),
            DataPoint(A: 0.35, B: 0.2155),
            DataPoint(A: 0.40, B: 0.2104),
            DataPoint(A: 0.45, B: 0.2061),
            DataPoint(A: 0.50, B: 0.2032),
            DataPoint(A: 0.55, B: 0.2020),
            DataPoint(A: 0.60, B: 0.2034),
            DataPoint(A: 0.70, B: 0.2165),
            DataPoint(A: 0.725, B: 0.2230),
            DataPoint(A: 0.75, B: 0.2313),
            DataPoint(A: 0.775, B: 0.2417),
            DataPoint(A: 0.80, B: 0.2546),
            DataPoint(A: 0.825, B: 0.2706),
            DataPoint(A: 0.85, B: 0.2901),
            DataPoint(A: 0.875, B: 0.3136),
            DataPoint(A: 0.90, B: 0.3415),
            DataPoint(A: 0.925, B: 0.3734),
            DataPoint(A: 0.95, B: 0.4084),
            DataPoint(A: 0.975, B: 0.4448),
            DataPoint(A: 1.0, B: 0.4805),
            DataPoint(A: 1.025, B: 0.5136),
            DataPoint(A: 1.05, B: 0.5427),
            DataPoint(A: 1.075, B: 0.5677),
            DataPoint(A: 1.10, B: 0.5883),
            DataPoint(A: 1.125, B: 0.6053),
            DataPoint(A: 1.15, B: 0.6191),
            DataPoint(A: 1.20, B: 0.6393),
            DataPoint(A: 1.25, B: 0.6518),
            DataPoint(A: 1.30, B: 0.6589),
            DataPoint(A: 1.35, B: 0.6621),
            DataPoint(A: 1.40, B: 0.6625),
            DataPoint(A: 1.45, B: 0.6607),
            DataPoint(A: 1.50, B: 0.6573),
            DataPoint(A: 1.55, B: 0.6528),
            DataPoint(A: 1.60, B: 0.6474),
            DataPoint(A: 1.65, B: 0.6413),
            DataPoint(A: 1.70, B: 0.6347),
            DataPoint(A: 1.75, B: 0.6280),
            DataPoint(A: 1.80, B: 0.6210),
            DataPoint(A: 1.85, B: 0.6141),
            DataPoint(A: 1.90, B: 0.6072),
            DataPoint(A: 1.95, B: 0.6003),
            DataPoint(A: 2.00, B: 0.5934),
            DataPoint(A: 2.05, B: 0.5867),
            DataPoint(A: 2.10, B: 0.5804),
            DataPoint(A: 2.15, B: 0.5743),
            DataPoint(A: 2.20, B: 0.5685),
            DataPoint(A: 2.25, B: 0.5630),
            DataPoint(A: 2.30, B: 0.5577),
            DataPoint(A: 2.35, B: 0.5527),
            DataPoint(A: 2.40, B: 0.5481),
            DataPoint(A: 2.45, B: 0.5438),
            DataPoint(A: 2.50, B: 0.5397),
            DataPoint(A: 2.60, B: 0.5325),
            DataPoint(A: 2.70, B: 0.5264),
            DataPoint(A: 2.80, B: 0.5211),
            DataPoint(A: 2.90, B: 0.5168),
            DataPoint(A: 3.00, B: 0.5133),
            DataPoint(A: 3.10, B: 0.5105),
            DataPoint(A: 3.20, B: 0.5084),
            DataPoint(A: 3.30, B: 0.5067),
            DataPoint(A: 3.40, B: 0.5054),
            DataPoint(A: 3.50, B: 0.5040),
            DataPoint(A: 3.60, B: 0.5030),
            DataPoint(A: 3.70, B: 0.5022),
            DataPoint(A: 3.80, B: 0.5016),
            DataPoint(A: 3.90, B: 0.5010),
            DataPoint(A: 4.00, B: 0.5006),
            DataPoint(A: 4.20, B: 0.4998),
            DataPoint(A: 4.40, B: 0.4995),
            DataPoint(A: 4.60, B: 0.4992),
            DataPoint(A: 4.80, B: 0.4990),
            DataPoint(A: 5.00, B: 0.4988),
        ]
    }

    static var g7: [DragModel.DataPoint] {
        return [
            DataPoint(A: 0.00, B: 0.1198),
            DataPoint(A: 0.05, B: 0.1197),
            DataPoint(A: 0.10, B: 0.1196),
            DataPoint(A: 0.15, B: 0.1194),
            DataPoint(A: 0.20, B: 0.1193),
            DataPoint(A: 0.25, B: 0.1194),
            DataPoint(A: 0.30, B: 0.1194),
            DataPoint(A: 0.35, B: 0.1194),
            DataPoint(A: 0.40, B: 0.1193),
            DataPoint(A: 0.45, B: 0.1193),
            DataPoint(A: 0.50, B: 0.1194),
            DataPoint(A: 0.55, B: 0.1193),
            DataPoint(A: 0.60, B: 0.1194),
            DataPoint(A: 0.65, B: 0.1197),
            DataPoint(A: 0.70, B: 0.1202),
            DataPoint(A: 0.725, B: 0.1207),
            DataPoint(A: 0.75, B: 0.1215),
            DataPoint(A: 0.775, B: 0.1226),
            DataPoint(A: 0.80, B: 0.1242),
            DataPoint(A: 0.825, B: 0.1266),
            DataPoint(A: 0.85, B: 0.1306),
            DataPoint(A: 0.875, B: 0.1368),
            DataPoint(A: 0.90, B: 0.1464),
            DataPoint(A: 0.925, B: 0.1660),
            DataPoint(A: 0.95, B: 0.2054),
            DataPoint(A: 0.975, B: 0.2993),
            DataPoint(A: 1.0, B: 0.3803),
            DataPoint(A: 1.025, B: 0.4015),
            DataPoint(A: 1.05, B: 0.4043),
            DataPoint(A: 1.075, B: 0.4034),
            DataPoint(A: 1.10, B: 0.4014),
            DataPoint(A: 1.125, B: 0.3987),
            DataPoint(A: 1.15, B: 0.3955),
            DataPoint(A: 1.20, B: 0.3884),
            DataPoint(A: 1.25, B: 0.3810),
            DataPoint(A: 1.30, B: 0.3732),
            DataPoint(A: 1.35, B: 0.3657),
            DataPoint(A: 1.40, B: 0.3580),
            DataPoint(A: 1.50, B: 0.3440),
            DataPoint(A: 1.55, B: 0.3376),
            DataPoint(A: 1.60, B: 0.3315),
            DataPoint(A: 1.65, B: 0.3260),
            DataPoint(A: 1.70, B: 0.3209),
            DataPoint(A: 1.75, B: 0.3160),
            DataPoint(A: 1.80, B: 0.3117),
            DataPoint(A: 1.85, B: 0.3078),
            DataPoint(A: 1.90, B: 0.3042),
            DataPoint(A: 1.95, B: 0.3010),
            DataPoint(A: 2.00, B: 0.2980),
            DataPoint(A: 2.05, B: 0.2951),
            DataPoint(A: 2.10, B: 0.2922),
            DataPoint(A: 2.15, B: 0.2892),
            DataPoint(A: 2.20, B: 0.2864),
            DataPoint(A: 2.25, B: 0.2835),
            DataPoint(A: 2.30, B: 0.2807),
            DataPoint(A: 2.35, B: 0.2779),
            DataPoint(A: 2.40, B: 0.2752),
            DataPoint(A: 2.45, B: 0.2725),
            DataPoint(A: 2.50, B: 0.2697),
            DataPoint(A: 2.55, B: 0.2670),
            DataPoint(A: 2.60, B: 0.2643),
            DataPoint(A: 2.65, B: 0.2615),
            DataPoint(A: 2.70, B: 0.2588),
            DataPoint(A: 2.75, B: 0.2561),
            DataPoint(A: 2.80, B: 0.2533),
            DataPoint(A: 2.85, B: 0.2506),
            DataPoint(A: 2.90, B: 0.2479),
            DataPoint(A: 2.95, B: 0.2451),
            DataPoint(A: 3.00, B: 0.2424),
            DataPoint(A: 3.10, B: 0.2368),
            DataPoint(A: 3.20, B: 0.2313),
            DataPoint(A: 3.30, B: 0.2258),
            DataPoint(A: 3.40, B: 0.2205),
            DataPoint(A: 3.50, B: 0.2154),
            DataPoint(A: 3.60, B: 0.2106),
            DataPoint(A: 3.70, B: 0.2060),
            DataPoint(A: 3.80, B: 0.2017),
            DataPoint(A: 3.90, B: 0.1975),
            DataPoint(A: 4.00, B: 0.1935),
            DataPoint(A: 4.20, B: 0.1861),
            DataPoint(A: 4.40, B: 0.1793),
            DataPoint(A: 4.60, B: 0.1730),
            DataPoint(A: 4.80, B: 0.1672),
            DataPoint(A: 5.00, B: 0.1618),
        ]
    }
}
