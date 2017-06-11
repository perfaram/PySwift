import Python
import PySwift_None

public class PythonList : PythonObject, ExpressibleByArrayLiteral {
    
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
}

public func __bridgeToPython<C: Collection>(_ coll: C) -> PythonList {
    return PythonList(fromCollection: coll)
}

public func __bridgeElementsToPython(_ dict: Dictionary<String, BridgeableToPython>) -> Dictionary<String, PythonBridge> {
    return dict.mapValues{ $0.bridgeToPython() }
}

public func __bridgeElementsToPython<C: Collection>(_ coll: C) -> [PythonBridge] where C.Iterator.Element : BridgeableToPython {
    return coll.map { (obj: BridgeableToPython) -> PythonBridge in
        obj.bridgeToPython()
    }
}

public func __bridgeElementsToPython(_ dict: Dictionary<String, BridgeableToPython?>) -> Dictionary<String, PythonBridge> {
    return dict.mapValues{
        guard let value = $0 else { return PythonNone() }
        return value.bridgeToPython()
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

extension Dictionary {
    func mapValues<T>(_ transform: (Value)->T) -> Dictionary<Key,T> {
        var resultDict = [Key: T]()
        for (k, v) in self {
            resultDict[k] = transform(v)
        }
        return resultDict
    }
}
