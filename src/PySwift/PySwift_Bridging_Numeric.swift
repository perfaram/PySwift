import Python
import PySwift_None

public class PythonInt : PythonBridge, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public required init(integerLiteral value: IntegerLiteralType){
        pythonObjPtr = PyInt_FromLong(value)
    }
    
    init(ptr: PythonObjectPointer?) {
        self.pythonObjPtr = ptr ?? PyNone_Get()
    }
    
    public private(set) var pythonObjPtr: PythonObjectPointer?
}

public class PythonFloat : PythonBridge, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public required init(floatLiteral value: FloatLiteralType){
        pythonObjPtr = PyFloat_FromDouble(value)
    }
    
    init(ptr: PythonObjectPointer?) {
        self.pythonObjPtr = ptr ?? PyNone_Get()
    }
    
    public private(set) var pythonObjPtr: PythonObjectPointer?
}

extension Int : PythonBridgeable {
    public func bridgeToPython() -> PythonBridge {
        return PythonInt(ptr: PyInt_FromLong(self))
    }
}

extension Float : PythonBridgeable {
    public func bridgeToPython() -> PythonBridge {
        return PythonFloat(ptr: PyFloat_FromDouble(Double(self)))
    }
}

extension Double : PythonBridgeable {
    public func bridgeToPython() -> PythonBridge {
        return PythonFloat(ptr: PyFloat_FromDouble(self))
    }
}

func __bridgeToPython<I: Integer>(_ int: I) -> PythonBridge {
    return PythonInt(ptr: PyInt_FromLong(int as! Int))
}

func __bridgeToPython(_ float: Float) -> PythonBridge {
    return PythonInt(ptr: PyFloat_FromDouble(Double(float)))
}

func __bridgeToPython(_ double: Double) -> PythonBridge {
    return PythonInt(ptr: PyFloat_FromDouble(double))
}
