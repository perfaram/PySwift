import Python
import PySwift_None

public class PythonInt : PythonObject, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public required init(integerLiteral value: IntegerLiteralType){
        super.init(ptr: PyInt_FromLong(value))
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

public class PythonFloat : PythonObject, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public required init(floatLiteral value: FloatLiteralType){
        super.init(ptr: PyFloat_FromDouble(value))
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

extension Int : BridgeableToPython {
    public func bridgeToPython() -> PythonBridge {
        return PythonInt(ptr: PyInt_FromLong(self))
    }
}

extension Float : BridgeableToPython {
    public func bridgeToPython() -> PythonBridge {
        return PythonFloat(ptr: PyFloat_FromDouble(Double(self)))
    }
}

extension Double : BridgeableToPython {
    public func bridgeToPython() -> PythonBridge {
        return PythonFloat(ptr: PyFloat_FromDouble(self))
    }
}

public func __bridgeToPython<I: Integer>(_ int: I) -> PythonBridge {
    return PythonInt(ptr: PyInt_FromLong(int as! Int))
}

public func __bridgeToPython(_ float: Float) -> PythonBridge {
    return PythonFloat(ptr: PyFloat_FromDouble(Double(float)))
}

public func __bridgeToPython(_ double: Double) -> PythonBridge {
    return PythonFloat(ptr: PyFloat_FromDouble(double))
}

public func __bridgeFromPython(_ int: PythonInt) -> Int? {
    guard !int.isNone else { return nil }
    return Int(PyInt_AsLong(int.pythonObjPtr))
}

public func __bridgeFromPython(_ float: PythonFloat) -> Float? {
    guard !float.isNone else { return nil }
    return Float(PyFloat_AsDouble(float.pythonObjPtr))
}

public func __bridgeFromPython(_ double: PythonFloat) -> Double? {
    guard !double.isNone else { return nil }
    return Double(PyFloat_AsDouble(double.pythonObjPtr))
}

