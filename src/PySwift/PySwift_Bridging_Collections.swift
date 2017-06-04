import Python
import PySwift_None

public class PythonList : PythonObject, ExpressibleByArrayLiteral {
    
    public convenience required init(arrayLiteral elements: Any...) {
        self.init(array: elements)
    }
    
    public required init(array elements: [Any]) {
        super.init(ptr: PyList_New(elements.count))
        
        for (index, element) in elements.enumerated() {
            guard let element = element as? PythonBridgeable else { continue }
            let to_append = element.bridgeToPython()
            PyList_SetItem(pythonObjPtr, index, to_append.pythonObjPtr)
        }
    }
    
    public required init<C: Collection>(fromCollection collection: C) {
        super.init(ptr: PyList_New(0)) //because getting count on Collections is only guaranteed to be O(*n*)
        var iterator = collection.makeIterator()
        var idx = 0
        while let element = iterator.next() {
            guard let element = element as? PythonBridgeable else { continue }
            let to_append = element.bridgeToPython()
            PyList_Append(pythonObjPtr, to_append.pythonObjPtr)
            idx += 1
        }
    }
    
    override init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

public func __bridgeToPython<C: Collection>(_ coll: C) -> PythonList {
    return PythonList(fromCollection: coll)
}
