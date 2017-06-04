import Python
import PySwift_None

public class PythonInt : PythonObject, ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public required init(integerLiteral value: IntegerLiteralType){
        super.init(ptr: PyInt_FromLong(value))
    }
    
    override init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

public class PythonFloat : PythonObject, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public required init(floatLiteral value: FloatLiteralType){
        super.init(ptr: PyFloat_FromDouble(value))
    }
    
    override init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
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
