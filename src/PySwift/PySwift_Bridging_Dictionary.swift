import Python
import PySwift_ObjC

public class PythonDictionary : PythonObject, BridgeableFromPython, ExpressibleByDictionaryLiteral {
    
    public typealias Key = AnyHashable
    public typealias Value = Any?
    
    public required init(dictionaryLiteral elements: (AnyHashable, Any?)...) {
        super.init(ptr: PyDict_New())
        
        for (_, element) in elements.enumerated() {
            let key = element.0
            let value = element.1
            
            var value_to_append : PythonObjectPointer
            var key_to_append : PythonObjectPointer
            
            if let pointer = (key as? BridgeableToPython)?.bridgeToPython().pythonObjPtr {
                key_to_append = pointer
            }
            else {
                continue
            }
            
            if let pointer = (value as? BridgeableToPython)?.bridgeToPython().pythonObjPtr {
                value_to_append = pointer
            }
            else {
                value_to_append = PyNone_Get()
            }
            
            PyDict_SetItem(pythonObjPtr, key_to_append, value_to_append)
        }
    }
    
    public required init(dictionary: [AnyHashable : Any?]) {
        super.init(ptr: PyDict_New())
        
        for (key, value) in dictionary {
            var value_to_append : PythonObjectPointer
            var key_to_append : PythonObjectPointer
            
            if let pointer = (key as? BridgeableToPython)?.bridgeToPython().pythonObjPtr {
                key_to_append = pointer
            }
            else {
                continue
            }
            
            if let pointer = (value as? BridgeableToPython)?.bridgeToPython().pythonObjPtr {
                value_to_append = pointer
            }
            else {
                value_to_append = PyNone_Get()
            }
            
            PyDict_SetItem(pythonObjPtr, key_to_append, value_to_append)
        }
    }
    
    public convenience init(_ pythonUntypedObject: PythonObject) {
        self.init(ptr: pythonUntypedObject.pythonObjPtr)
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
    
    public init(ptr: UnsafeMutablePointer<PyDictObject>) {
        let pyObjPtr = ptr.withMemoryRebound(to: PyObject.self, capacity: 1, { pyobjPtr -> PythonObjectPointer in
            return pyobjPtr
        })
        super.init(ptr: pyObjPtr)
    }
    
    public typealias SwiftMatchingType = Dictionary<AnyHashable, Any?>
    
    public func typedBridgeFromPython() -> Dictionary<AnyHashable, Any?>? {
        return __bridgeFromPython(self)
    }
}

public func __bridgeToPython(_ dict: [AnyHashable : Any?]) -> PythonDictionary {
    return PythonDictionary(dictionary: dict)
}

public func __bridgeFromPython(_ dict: PythonDictionary) -> [AnyHashable : Any?]? {
    guard !dict.isNone else { return nil }
    
    let retDict = dict.pythonObjPtr!.withMemoryRebound(to: PyObject.self, capacity: 1, { (pyobjPtr) -> [AnyHashable : Any?]? in
        guard PyDict_CheckIsDict(pyobjPtr) else { return nil }
        
        var retDict = [AnyHashable : Any?]()
        
        PyDict_Enumerate(pyobjPtr, { (key, value, pos) -> Bool in
            var swKey : AnyHashable
            var swValue : Any?
            
            if (key == PyNone_Get()) {
                swKey = PythonNone()
            } else {
                if let type = PythonBridgingManager.sharedInstance.getBridge(key) as? PythonBridge.Type {
                    let pyBridge = type.init(ptr: key) as! UntypedBridgeableFromPython
                    if let swKeyIntermediate = pyBridge.bridgeFromPython() as? AnyHashable {
                        swKey = swKeyIntermediate
                    } else {
                        swKey = PythonObject(ptr: key)
                    }
                } else {
                    swKey = PythonObject(ptr: key)
                }
            }
            
            if (value == PyNone_Get()) {
                swValue = nil
            } else {
                if let type = PythonBridgingManager.sharedInstance.getBridge(value) as? PythonBridge.Type {
                    let pyBridge = type.init(ptr: value) as! UntypedBridgeableFromPython
                    swValue = pyBridge.bridgeFromPython()
                } else {
                    swValue = PythonObject(ptr: value)
                }
            }
            
            retDict[swKey] = swValue
            return true
        })
        
        return retDict
    })
    
    return retDict
}

public func __bridgeElementsToPython(_ dict: Dictionary<String, BridgeableToPython>) -> Dictionary<String, PythonBridge> {
    return dict.mapValues{ $0.bridgeToPython() }
}

public func __bridgeElementsToPython(_ dict: Dictionary<String, BridgeableToPython?>) -> Dictionary<String, PythonBridge> {
    return dict.mapValues{
        guard let value = $0 else { return PythonNone() }
        return value.bridgeToPython()
    }
}

extension Dictionary {
    func mapValues<T>(_ transform: (Value)->T) -> Dictionary<Key,T> {
        var resultDict = [Key: T]()
        for (k, v) in self {
            resultDict[k] = transform(v)
        }
        return resultDict
    }
}

