import Python
import PySwift_ObjC

private func translateBoolToPythonObjectPointer(_ bool: Bool) -> PythonObjectPointer {
    if (bool) {
        return PyBool_True()
    }
    else {
        return PyBool_False()
    }
}

public class PythonBool : PythonObject, BridgeableFromPython, ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    
    static func convertFromBooleanLiteral(value: Bool) -> PythonBool {
        return self.init(ptr: translateBoolToPythonObjectPointer(value))
    }
    
    public required init(booleanLiteral value: BooleanLiteralType) {
        super.init(ptr: translateBoolToPythonObjectPointer(value))
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
    
    public typealias SwiftMatchingType = Bool
    public func typedBridgeFromPython() -> Bool? {
        guard !self.isNone else { return nil }
        let truthValue = PyObject_IsTrue(self.pythonObjPtr)
        return (truthValue == 0) ? false : true
    }
}

extension Bool : BridgeableToPython {
    public func bridgeToPython() -> PythonBridge {
        return PythonBool(ptr: translateBoolToPythonObjectPointer(self))
    }
}

public func __bridgeToPython(_ bool: Bool) -> PythonBridge {
    return PythonBool(ptr: translateBoolToPythonObjectPointer(bool))
}

public func __bridgeFromPython(_ bool: PythonBool) -> Bool? {
    guard !bool.isNone else { return nil }
    let truthValue = PyObject_IsTrue(bool.pythonObjPtr)
    return (truthValue == 0) ? false : true
}

