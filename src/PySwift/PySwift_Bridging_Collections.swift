import Python
import PySwift_ObjC

public class PythonList : PythonObject, BridgeableFromPython, ExpressibleByArrayLiteral {
    
    public convenience required init(arrayLiteral elements: Any...) {
        self.init(array: elements)
    }
    
    public required init(array elements: [Any]) {
        super.init(ptr: PyList_New(elements.count))
        
        for (index, element) in elements.enumerated() {
            var to_append : PythonObjectPointer
            
            if let pointer = (element as? BridgeableToPython)?.bridgeToPython().pythonObjPtr {
                to_append = pointer
            }
            else {
                to_append = PyNone_Get()
            }
            
            PyList_SetItem(pythonObjPtr, index, to_append)
        }
    }
    
    public convenience init(_ pythonUntypedObject: PythonObject) {
        self.init(ptr: pythonUntypedObject.pythonObjPtr)
    }
    
    @available(*, unavailable, message: "Use PythonDictionary for bridging dictionaries")
    public required init(fromCollection collection: Dictionary<AnyHashable, Any>) {
        fatalError()
    }
    
    public required init<C: Collection>(fromCollection collection: C) {
        super.init(ptr: PyList_New(0)) //because getting count on Collections is only guaranteed to be O(*n*)
        var iterator = collection.makeIterator()
        
        while let element = iterator.next() {
            var to_append : PythonObjectPointer
            
            if let pointer = (element as? BridgeableToPython)?.bridgeToPython().pythonObjPtr {
                to_append = pointer
            }
            else {
                to_append = PyNone_Get()
            }
            
            PyList_Append(pythonObjPtr, to_append)
        }
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
    
    public init(ptr: UnsafeMutablePointer<PyListObject>) {
        let pyObjPtr = ptr.withMemoryRebound(to: PyObject.self, capacity: 1, { pyobjPtr -> PythonObjectPointer in
            return pyobjPtr
        })
        super.init(ptr: pyObjPtr)
    }
    
    public typealias SwiftMatchingType = Array<Any?>
    public func typedBridgeFromPython() -> Array<Any?>? {
        return __bridgeFromPython(self)
    }
    
    public func shallowBridgeFromPython() -> Array<PythonObject>? {
        guard !self.isNone else { return nil }
        
        var retArray = Array<PythonObject>()
        
        self.pythonObjPtr!.withMemoryRebound(to: PyObject.self, capacity: 1, { (pyobjPtr) -> Void in
            let len : UInt
            let seq = PySequence_Fast(pyobjPtr, "expected a sequence")
            let size = PySequence_Size(pyobjPtr)
            if (size < 0) {
                print(PythonSwift.retrievePythonException())
            }
            len = UInt(size)
            
            if (PyList_CheckIsList(seq!)) {
                for i in 0..<len {
                    let item = PyList_Get_Item(seq!, i)
                    retArray.append(PythonObject(ptr: item))
                }
            } else {
                for i in 0..<len {
                    let item = PyTuple_Get_Item(seq!, i)
                    retArray.append(PythonObject(ptr: item))
                }
            }
            Py_DecRef(seq);
        })
        
        return retArray
    }
}

public func __bridgeToPython<C: Collection>(_ coll: C) -> PythonList {
    return PythonList(fromCollection: coll)
}

public func __bridgeFromPython(_ list: PythonList) -> Array<Any?>? {
    guard !list.isNone else { return nil }
    
    var retArray = Array<Any!>()
    
    list.pythonObjPtr!.withMemoryRebound(to: PyObject.self, capacity: 1, { (pyobjPtr) -> Void in
        let len : UInt
        let seq = PySequence_Fast(pyobjPtr, "expected a sequence")
        let size = PySequence_Size(pyobjPtr)
        if (size < 0) {
            print(PythonSwift.retrievePythonException())
        }
        len = UInt(size)
        
        if (PyList_CheckIsList(seq!)) {
            for i in 0..<len {
                let item = PyList_Get_Item(seq!, i)
                
                guard let type = PythonBridgingManager.sharedInstance.getBridge(item) as? PythonBridge.Type
                    else { retArray.append(PythonNone().bridgeFromPython()) ; continue }
                
                let pyBridge = type.init(ptr: item) as! UntypedBridgeableFromPython
                let swValue = pyBridge.bridgeFromPython()
                
                retArray.append(swValue)
            }
        } else {
            for i in 0..<len {
                let item = PyTuple_Get_Item(seq!, i)
                guard let type = PythonBridgingManager.sharedInstance.getBridge(item) as? PythonBridge.Type
                    else { retArray.append(PythonNone().bridgeFromPython()) ; continue }
                
                let pyBridge = type.init(ptr: item) as! UntypedBridgeableFromPython
                let swValue = pyBridge.bridgeFromPython()
                
                retArray.append(swValue)
            }
        }
        Py_DecRef(seq);
    })
    
    return retArray
}

public func __bridgeElementsToPython<C: Collection>(_ coll: C) -> [PythonBridge] where C.Iterator.Element : BridgeableToPython {
    return coll.map { (obj: BridgeableToPython) -> PythonBridge in
        obj.bridgeToPython()
    }
}

public func __bridgeElementsToPython<C: Collection>(_ coll: C) -> [PythonBridge] where C.Iterator.Element == Optional<BridgeableToPython> {
    return coll.map { (obj: BridgeableToPython?) -> PythonBridge in
        guard let value = obj else { return PythonNone() }
        return value.bridgeToPython()
    }
}

public extension Collection /*: BridgeableToPython*/ {
    func bridgeToPython() -> PythonBridge {
        return PythonList(fromCollection: self)
    }
}
