import PySwift_ObjC

extension UnsafeMutableRawPointer : CVarArg {
    /// Transform `self` into a series of machine words that can be
    /// appropriately interpreted by C varargs.
    public var _cVarArgEncoding: [Int] {
        return _encodeBitsAsWords(self)
    }
}

public func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

public func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}

/// Compute the prefix sum of `seq`.
public func scan<
    S : Sequence, U
    >(_ seq: S, _ initial: U, _ combine: (U, S.Iterator.Element) -> U) -> [U] {
    var result: [U] = []
    result.reserveCapacity(seq.underestimatedCount)
    var runningResult = initial
    for element in seq {
        runningResult = combine(runningResult, element)
        result.append(runningResult)
    }
    return result
}

public func withArrayOfCStrings<R>(
    _ args: [String], _ body: ([UnsafeMutablePointer<CChar>?]) -> R
    ) -> R {
    let argsCounts = Array(args.map { $0.utf8.count + 1 })
    let argsOffsets = [ 0 ] + scan(argsCounts, 0, +)
    let argsBufferSize = argsOffsets.last!
    
    var argsBuffer: [UInt8] = []
    argsBuffer.reserveCapacity(argsBufferSize)
    for arg in args {
        argsBuffer.append(contentsOf: arg.utf8)
        argsBuffer.append(0)
    }
    
    return argsBuffer.withUnsafeMutableBufferPointer {
        (argsBuffer) in
        let ptr = UnsafeMutableRawPointer(argsBuffer.baseAddress!).bindMemory(
            to: CChar.self, capacity: argsBuffer.count)
        var cStrings: [UnsafeMutablePointer<CChar>?] = argsOffsets.map { ptr + $0 }
        cStrings[cStrings.count - 1] = nil
        return body(cStrings)
    }
}

@inline(__always) public func prepareFor<T: WrappableInPython>() -> UnsafeMutablePointer<T> {
    let ptr = UnsafeMutablePointer<pyswift_PyObjWrappingSwift>.allocate(capacity: 1)
    let intermediate = unsafeBitCast(ptr, to: UnsafeMutablePointer<T>.self)
    return intermediate
}

@inline(__always) public func prepareFor<T>(_ pyType: T.Type) -> UnsafeMutablePointer<T> {
    return UnsafeMutablePointer<T>.allocate(capacity: 1)
}

@inline(__always) public func finishFor<T: AnyObject>(_ intermediate: UnsafeMutablePointer<T>) -> T where T: WrappableInPython {
    return intermediate.withMemoryRebound(to: pyswift_PyObjWrappingSwift.self, capacity: 1, { pyPtr -> T in
        let swiftyInstance : T = Unmanaged<T>.fromOpaque(pyPtr.pointee.wrapped_obj).takeRetainedValue()
        return swiftyInstance
    })
}

public func parseSelfAndArgs<S : WrappableInPython>(
    _ rawSelf : UnsafeMutablePointer<PyObject>?,
    _ pyArgs: UnsafeMutablePointer<PyObject>?,
    _ types: String,
    _ sfArgs: UnsafeMutableRawPointer...) -> S? where S : AnyObject
{
    let pySelf = UnsafeMutableRawPointer(rawSelf!).bindMemory(to: pyswift_PyObjWrappingSwift.self, capacity: 1).pointee
    let swSelf : S = Unmanaged<S>.fromOpaque(pySelf.wrapped_obj).takeRetainedValue()
    
    let retCode = withVaList(sfArgs) { p -> Int32 in
        return PyArg_VaParse(pyArgs, types, p)
    }
    guard retCode > 0 else {
        PythonSwift.setPythonException( PythonSwift.retrievePythonException()! )
        return nil
    }
    guard type(of: swSelf) == S.self else {
        PythonSwift.setPythonException( PySwiftError.UnexpectedTypeError(expected: S.self, got: type(of: swSelf)) )
        return nil
    }
    
    return swSelf
}

public func parseSelfAndArgs<S : PythonObject>(
    _ rawSelf : UnsafeMutablePointer<PyObject>?,
    _ pyArgs: UnsafeMutablePointer<PyObject>?,
    _ types: String,
    _ sfArgs: UnsafeMutableRawPointer...) -> S?
{
    let pySelf = UnsafeMutableRawPointer(rawSelf ?? PyNone_Get()).bindMemory(to: PyObject.self, capacity: 1)
    
    let retCode = withVaList(sfArgs) { p -> Int32 in
        return PyArg_VaParse(pyArgs, types, p)
    }
    guard retCode > 0 else {
        PythonSwift.setPythonException( PythonSwift.retrievePythonException()! )
        return nil
    }
    
    return S(ptr: pySelf)
}
