import Python
import PySwift_None

public typealias PythonObjectPointer = UnsafeMutablePointer<PyObject>

public func initPython() {
    Py_Initialize()
}

public func evalStatement(_ string: String) {
    PyRun_SimpleStringFlags(string, nil);
}

public func call(_ code: String, args:PythonBridge...) -> PythonObject {
    let main = pythonImport(name: "__main__")
    return main.call(code, args: args)
}

internal func wrapEvalString( string : String) -> String {
    return "def _swiftpy_eval_wrapper_():\n" +
        "    result = \(string)\n" +
    "    return result"
}

//TODO handle def case
public func eval(_ code:String) -> PythonObject {
    let wrappedCode = wrapEvalString(string:code)
    evalStatement(wrappedCode)
    let main = pythonImport(name: "__main__")
    return main.call("_swiftpy_eval_wrapper_")
}

public func pyprint(_ code:String) -> PythonObject {
    let main = pythonImport(name: "__main__")
    let maindict = PyModule_GetDict(main.pythonObjPtr)
    
    //let builtins = pythonImport(name: "__builtin__")
    //let builtinsdict = PyModule_GetDict(builtins.pythonObjPtr)
    let builtinsdict = PyEval_GetBuiltins()
    
    let ret = PyDict_Merge(maindict, builtinsdict, 0)
    guard ret == 0 else { return PythonObject() }
    
    let pFunc = PyDict_GetItemString(maindict, "print")
    guard PyCallable_Check(pFunc) == 1 else { return PythonObject() }
    
    return main.call("print", args: code.bridgeToPython())
}

public protocol PythonBridgeable {
    func bridgeToPython() -> PythonBridge
}

public protocol PythonBridge : CustomStringConvertible {
    var pythonObjPtr: PythonObjectPointer? { get }
    var description:String { get }
    //TODO test the case of method with self
    @discardableResult func call(_ funcName:String, args:PythonBridge...) -> PythonObject
    @discardableResult func call(_ funcName:String, args:[PythonBridge]) -> PythonObject
    func toPythonString() -> PythonString
    func attr(_ name:String) -> PythonObject
    func setAttr(_ name:String, value:PythonBridge)
}

extension PythonBridge {
    @discardableResult public func call(_ funcName:String, args:PythonBridge...) -> PythonObject{
        return call(funcName, args:args)
    }
    
    @discardableResult public func call(_ funcName:String, args:[PythonBridge]) -> PythonObject {
        let pFunc = PyObject_GetAttrString(pythonObjPtr!, funcName)
        guard PyCallable_Check(pFunc) == 1 else { return PythonObject() }
        let pArgs = PyTuple_New(args.count)
        for (idx,obj) in args.enumerated() {
            let i:Int = idx
            PyTuple_SetItem(pArgs, i, obj.pythonObjPtr!)
        }
        let pValue = PyObject_CallObject(pFunc, pArgs)
        Py_DecRef(pArgs)
        return PythonObject(ptr: pValue)
    }
    
    public func toPythonString() -> PythonString {
        let ptr = PyObject_Str(pythonObjPtr!)
        return PythonString(ptr:ptr)
    }
    
    public func attr(_ name:String) -> PythonObject {
        guard PyObject_HasAttrString(pythonObjPtr!, name) == 1 else {return PythonObject()}
        return PythonObject(ptr:PyObject_GetAttrString(pythonObjPtr!, name))
    }
    
    public func setAttr(_ name:String, value:PythonBridge) {
        PyObject_SetAttrString(pythonObjPtr!, name, value.pythonObjPtr!)
    }
    
    public var description: String {
        let pyString = toPythonString()
        let cstr:UnsafePointer<CChar> = UnsafePointer(PyString_AsString(pyString.pythonObjPtr!)!)
        return String(cString : cstr)
    }
    
}

public func pythonImport(name:String) -> PythonObject{
    let module = PyImport_ImportModule(name)
    return PythonObject(ptr:module)
}

//TODO
public func convertPythonObjectPointer(cPyObj ptr:PythonObjectPointer) -> PythonBridge {
    //NOT impl yet
    return PythonObject(ptr:ptr)
}

public class PythonObject : CustomDebugStringConvertible, PythonBridge {
    let ptr: PythonObjectPointer
    public init() {
        ptr = PyNone_Get()
    }
    init(ptr:PythonObjectPointer?) {
        self.ptr = ptr ?? PyNone_Get()
    }
    public var pythonObjPtr:PythonObjectPointer? {
        return ptr
    }
    
    
    public var debugDescription: String {
        get {
            //guard let pptr = ptr else { return "nil" }
            return ptr.debugDescription
        }
    }
}
