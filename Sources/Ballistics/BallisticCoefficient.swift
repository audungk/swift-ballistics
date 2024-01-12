import Foundation

struct BallisticCoefficient {

    let piRho = 2.08551e-04

    enum Kind {
        case ballisticCoefficient
        case formFactor
    }

    let value: Double
    let kind: BallisticCoefficient.Kind
    let dragModel: DragModel

    init(_ value: Double, dragModel: DragModel.Kind){
        assert(value > 0)

        self.value = value
        self.dragModel = DragModel(kind: dragModel)
        self.kind = .ballisticCoefficient
    }

    func drag(at mach: Double) -> Double {
        dragModel.drag(at: mach) * piRho
    }
}
