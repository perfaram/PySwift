import Python
import PySwift_None

public class PythonString : PythonBridge, ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public required init(stringLiteral:String) {
        pythonObjPtr = PyString_FromString(stringLiteral)
    }
    
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        pythonObjPtr = PyString_FromString(value)
    }
    
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        pythonObjPtr = PyString_FromString("\(value)")
    }
    
    init(ptr: PythonObjectPointer?) {
        self.pythonObjPtr = ptr ?? PyNone_Get()
    }
    
    public private(set) var pythonObjPtr: PythonObjectPointer?
}

public func __bridgeToPython(_ str: String) -> PythonString {
    return PythonString(ptr: PyString_FromString(str))
}

extension String : PythonBridgeable {
    public func bridgeToPython() -> PythonBridge {
        return PythonString(ptr: PyString_FromString(self))
    }
}
