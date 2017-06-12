import Python
import PySwift_ObjC

public class PythonBridgingManager {
    private lazy var bridgesDict : [PythonTypeObjectPointer : UntypedBridgeableFromPython.Type] = {
        var dict = [PythonTypeObjectPointer : UntypedBridgeableFromPython.Type]()
        
        dict[getPointerToPythonObjectType(&PyInt_Type)] = (PythonInt.self)
        dict[getPointerToPythonObjectType(&PyFloat_Type)] = (PythonFloat.self)
        dict[getPointerToPythonObjectType(&PyString_Type)] = (PythonString.self)
        dict[getPointerToPythonObjectType(&PyList_Type)] = (PythonList.self)
        
        return dict
    }()
    
    public static let sharedInstance = PythonBridgingManager()
    
    public func registerBridge(type: UnsafePointer<PyTypeObject>, to: UntypedBridgeableFromPython.Type) {
        bridgesDict[type] = (to.self)
    }
    
    public func getBridge(_ forObject: PythonObjectPointer) -> UntypedBridgeableFromPython.Type? {
        let ob_type = forObject.pointee.ob_type
        return bridgesDict[ob_type!]
    }
}
