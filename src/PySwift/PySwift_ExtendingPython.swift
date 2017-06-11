import Python
import PySwift_ObjC

public func buildPyTypeObject(named cls_name: String,
                              inModule mdl_name: String,
                              sized size: size_t,
                              flagged flags: Int64,
                              documented doc: String,
                              pyNew: @escaping newfunc = PyType_GenericNew,
                              pyInit: @escaping initproc,
                              methodList: UnsafeMutablePointer<PyMethodDef>) -> UnsafeMutablePointer<PyTypeObject>
{
    let pyTypeObj = calloc(1, MemoryLayout<PyTypeObject>.size).assumingMemoryBound(to: PyTypeObject.self)
    
    memcpy(pyTypeObj, &blankTypeObject, MemoryLayout<PyTypeObject>.size)
    let classIdentifier = mdl_name + "." + cls_name
    
    pyTypeObj.pointee.tp_name = (classIdentifier as NSString).utf8String
    pyTypeObj.pointee.tp_doc = (classIdentifier as NSString).utf8String
    pyTypeObj.pointee.tp_basicsize = size
    pyTypeObj.pointee.tp_flags = (flags == -1) ? Py_TPFLAGS_DEFAULT_value : Int(flags)
    pyTypeObj.pointee.tp_new = pyNew;
    pyTypeObj.pointee.tp_init = pyInit;
    pyTypeObj.pointee.tp_methods = methodList;
    
    return pyTypeObj
}

public protocol WrappableInPython {
    static func getPythonTypeDefinition() -> UnsafeMutablePointer<PyTypeObject>
    static func getPythonMethods() -> UnsafeMutablePointer<PyMethodDef>
}
