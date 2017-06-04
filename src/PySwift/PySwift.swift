import Python
import PySwift_None

public typealias PythonObjectPointer = UnsafeMutablePointer<PyObject>

public func initPython() {
    Py_Initialize()
    let main = pythonImport(name: "__main__")
    let maindict = PyModule_GetDict(main.pythonObjPtr)
    
    let builtinsdict = PyEval_GetBuiltins()
    
    guard PyDict_Merge(maindict, builtinsdict, 0) == 0 else { return }
}

public func importModule(named name: String) -> Bool {
    let main = pythonImport(name: "__main__")
    let maindict = PyModule_GetDict(main.pythonObjPtr)
    
    let module = pythonImport(name: name)
    
    guard PyDict_SetItemString(maindict, name, module.pythonObjPtr) == 0 else { return false }
    return true
}

public func evalStatement(_ string: String) {
    PyRun_SimpleStringFlags(string, nil);
}

@discardableResult public func call(_ code: String, args:PythonBridge...) -> PythonObject {
    let main = pythonImport(name: "__main__")
    return main.call(code, args: args)
}

@discardableResult public func call(_ funcName: String, positionalArgs: [PythonBridge], keywordArgs: Dictionary<String, PythonBridge>) -> PythonObject {
    let main = pythonImport(name: "__main__")
    return main.call(funcName, positionalArgs: positionalArgs, keywordArgs: keywordArgs)
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

public protocol PythonBridgeable {
    func bridgeToPython() -> PythonBridge
}

public protocol PythonBridge : CustomStringConvertible {
    var pythonObjPtr: PythonObjectPointer? { get }
    var description:String { get }
    //TODO test the case of method with self
    @discardableResult func call(_ funcName: String, positionalArgs: [PythonBridge], keywordArgs: Dictionary<String, PythonBridge>) -> PythonObject
    @discardableResult func call(_ funcName:String, args:PythonBridge...) -> PythonObject
    @discardableResult func call(_ funcName:String, args:[PythonBridge]) -> PythonObject
    
    func toPythonString() -> PythonString
    func attr(_ name:String) -> PythonObject
    func setAttr(_ name:String, value:PythonBridge)
}

public func ==(lhs: PythonBridge, rhs: PythonBridge) -> Bool {
    let ret = PyObject_RichCompareBool(lhs.pythonObjPtr!, rhs.pythonObjPtr!, Py_EQ)
    return (ret == 1)
}

extension PythonBridge {
    @discardableResult public func call(_ funcName: String, args: PythonBridge...) -> PythonObject {
        return call(funcName, args:args)
    }
    
    @discardableResult public func call(_ funcName: String, args: [PythonBridge]) -> PythonObject {
        let pFunc = PyObject_GetAttrString(pythonObjPtr!, funcName) //PyDict_GetItemString(module_dict, "functionName")
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
    
    @discardableResult public func call(_ funcName:String, keywordArgs: Dictionary<String, String>) -> PythonObject {
        return PythonObject()
    }
    
    @discardableResult public func call(_ funcName: String, positionalArgs: [PythonBridge], keywordArgs: Dictionary<String, PythonBridge>) -> PythonObject {
        let pFunc = PyObject_GetAttrString(pythonObjPtr!, funcName)
        guard PyCallable_Check(pFunc) == 1 else { return PythonObject() }
        
        let pArgs = PyTuple_New(positionalArgs.count)
        for (idx, obj) in positionalArgs.enumerated() {
            let i:Int = idx
            PyTuple_SetItem(pArgs, i, obj.pythonObjPtr!)
        }
        
        let pKeywords = PyDict_New()
        for (keyword, obj) in keywordArgs {
            PyDict_SetItemString(pKeywords, keyword, obj.pythonObjPtr!)
        }
        
        let pValue = PyObject_Call(pFunc, pArgs, pKeywords)
        Py_DecRef(pArgs)
        Py_DecRef(pKeywords)
        Py_DecRef(pFunc)
        
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

public class PythonObject : PythonBridge, CustomDebugStringConvertible {
    public private(set) var pythonObjPtr: PythonObjectPointer?
    
    public init() {
        pythonObjPtr = PyNone_Get()
    }
    init(ptr: PythonObjectPointer?) {
        self.pythonObjPtr = ptr ?? PyNone_Get()
        Py_IncRef(pythonObjPtr)
    }
    
    
    public var debugDescription: String {
        get {
            guard let ptr = pythonObjPtr else { return "nil" }
            return ptr.debugDescription
        }
    }
    
    deinit {
        Py_DecRef(pythonObjPtr)
    }
}
