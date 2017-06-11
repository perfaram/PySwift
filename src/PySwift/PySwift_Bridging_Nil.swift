import Python
import PySwift_None

public class PythonNone : PythonObject, ExpressibleByNilLiteral {
    
    public required init(nilLiteral: ()) {
        super.init(ptr: PyNone_Get())
    }
    
    override public init() {
        super.init(ptr: PyNone_Get())
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

public func __bridgeToPython(_ nil: ()) -> PythonNone {
    return PythonNone()
}

public func __bridgeToPython(_ optional: Optional<BridgeableToPython>) -> PythonBridge {
    guard let value = optional else { return PythonNone() }
    return value.bridgeToPython()
}

/* PRESERVED FOR WHEN SE-0143 GETS IMPLEMENTED
extension Optional : BridgeableToPython where Optional.Wrapped == BridgeableToPython {
    func bridgeToPython() -> PythonBridge {
        guard let value = self else { return PythonNone() }
        return value.bridgeToPython()
    }
}*/
