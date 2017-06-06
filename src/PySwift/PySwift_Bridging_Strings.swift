import Python
import PySwift_None

public class PythonString : PythonObject, ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public required init(stringLiteral:String) {
        super.init(ptr: PyString_FromString(stringLiteral))
    }
    
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        super.init(ptr: PyString_FromString(value))
    }
    
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        super.init(ptr: PyString_FromString("\(value)"))
    }
    
    public init(_ str:String) {
        super.init(ptr: PyString_FromString(str))
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

public func __bridgeToPython(_ str: String) -> PythonString {
    //guard let string = str else { return PythonNone() }
    return PythonString(ptr: PyString_FromString(str))
}

public func __bridgeFromPython(_ str: PythonString) -> String? {
    guard !str.isNone else { return nil }
    return String(cString: PyString_AsString(str.pythonObjPtr))
}

extension String : PythonBridgeable {
    public func bridgeToPython() -> PythonBridge {
        return PythonString(ptr: PyString_FromString(self))
    }
}
