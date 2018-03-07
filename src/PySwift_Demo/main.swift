import PySwift
import Python
import PySwift_ObjC

print("First things first : you absolutely have to initialize the Python interpreter before anything else.")
guard let PySwift = PythonSwift.sharedInstance else { exit(1) } //required before anything else

////////////////////////////////////
////////////////////////////////////

print("\nWhy not try a few simple things as a warm-up ?")

let addStr = PySwift.eval(statement: "1 + 1")
print("Eval'ing `1 + 1` yielded :", addStr)

////////////////////////////////////
////////////////////////////////////

let helloString = "hello world"
let helloPythonInitializer : PythonString = PythonString(helloString)
let helloPythonStringLiteral : PythonString = "hello world"
let helloPythonBridgingProtocolExtension = helloString.bridgeToPython()
let helloPythonBridgingFreeFloatingFunc = __bridgeToPython(helloString)

print("\nThere are many way to turn Swift objects to Python objects, but they all yield the same result. Let's compare all 4 ways of turning the string `hello world` in a Python object.")
    
print("Comparing objects from Swift :",
      (helloPythonInitializer == helloPythonStringLiteral) &&
      (helloPythonStringLiteral == helloPythonBridgingProtocolExtension) &&
      (helloPythonBridgingProtocolExtension == helloPythonBridgingFreeFloatingFunc))

let pythonComparator = "def compare(str1, str2, str3, str4):\n" +
"    return (str1 == str2 == str3 == str4)"
PySwift.execute(code: pythonComparator)
let compareResult = PySwift.call("compare", args:
    helloPythonInitializer,
                         helloPythonStringLiteral,
                         helloPythonBridgingProtocolExtension,
                         helloPythonBridgingFreeFloatingFunc)
print("Comparing objects in Python :", compareResult)

////////////////////////////////////
////////////////////////////////////

let text = "a text"
print("\nWe are now going to print `\(text)` in 2 differents ways")

PySwift.execute(code: "print '\(text)'") //one way

_ = PySwift.call("print", args: text.bridgeToPython()) //another way

////////////////////////////////////
////////////////////////////////////

print("\nAnd now we will show how to call a method on a Python object from Swift")

let lowercase: PythonString = "case-shifting string"
print(lowercase)
let uppercase = lowercase.call("upper")
print(uppercase)

////////////////////////////////////
////////////////////////////////////

print("\nAnother one : let's pass a Swift array to Python and have it return a random element")

guard PySwift.importModule(named: "random") else { print("Couldn't import the module named `random`, exiting !"); exit(1) } //like Python's "import random"

let defChooseFile = "def chooseFile(arr):\n" +
"    return random.choice(arr)"
PySwift.execute(code: defChooseFile) //load the code in the interpreter

let moutains: PythonList = ["Everest", "Kilimanjaro", "La Tournette", "Denali"]
let chose = PySwift.call("chooseFile", args: moutains)
print(chose)

////////////////////////////////////
////////////////////////////////////

print("\nThis is a showcase of the ability to mutate Python objects from Swift – for example, by changing an ivar.")

let defFoo = "class Foo:\n" +
             "    def __init__(self):\n" +
             "        print('Instantiating an instance of Foo, in Python...')\n" +
             "        self.bar = 'I am the `bar` ivar of Foo'"

PySwift.execute(code: defFoo)

let foo = PySwift.eval(statement: "Foo()")
let bar = foo.attribute("bar")
print("foo.bar =", bar)

let newBarVal:PythonString = "I'm the new bar"
print("Setting a new bar to our instance of Foo, from Swift...")
foo.setAttribute("bar", value: newBarVal)
let newBar = foo.attribute("bar")
print("foo.bar =", newBar)

////////////////////////////////////
////////////////////////////////////

print("\nCalling a Python function with named and positional arguments")

let sayHelloFn = "def sayHello(name, surname = \"\", times = 1):\n" +
"    for i in range(times):" +
"        print(\"Hello, \" + name + \" \" + surname + \"!\")"
PySwift.execute(code: sayHelloFn) //load the code in the interpreter

var keywordArgs : [String : BridgeableToPython] = ["times" : 3, "surname" : "Bond"]

var positionalArgs = ["James"]
PySwift.call("sayHello", positionalArgs: __bridgeElementsToPython(positionalArgs), keywordArgs: __bridgeElementsToPython(keywordArgs))

////////////////////////////////////
////////////////////////////////////

print("\nCalling a variadic Python function with named arguments")

let astonishingFunction = "from __future__ import print_function\n" +
"def astonishingFunction(*args, **kwargs):\n" +
"    for a in args:\n" +
"        print(a, end = ' ')\n" +
"    print(\"\\n\")\n" +
"    for k,v in kwargs.iteritems():\n" +
"        print(\"%s = %s\" % (k, v))"
PySwift.execute(code: astonishingFunction) //load the code in the interpreter

keywordArgs = ["First Key" : 17.18, "Second Key" : "Second value", "Third Key" : "3rd value"]
positionalArgs = ["This", "function", "is", "variadic :", "it", "may", "take", "as", "many", "arguments", "as", "wanted."]
PySwift.call("astonishingFunction", positionalArgs: __bridgeElementsToPython(positionalArgs), keywordArgs: __bridgeElementsToPython(keywordArgs))

////////////////////////////////////
////////////////////////////////////

print("\nOnce upon a time, there was a Swift class, a matching Python class, and a bridge class between the two")

public class MyFunClass { //this is the Swift class
    public var aString : String?
    public let aNumber : Double
    
    init(number: Double, string: String?) {
        aNumber = number
        aString = string
    }
}

//of course this isn't true bridging : there is 0 interactivity between PythonMyFunClass and MyFunClass. This will come soon.
public class PythonMyFunClass : PythonObject { //this is the bridge class
    public let pythonClass = "PythonMyFunClass"
    public let pythonCDecl = "class PythonMyFunClass(object):\n" + //this is the Python class
        "    __pyswift_swiftClass = \"MyFunClass\"\n" +
        "    @classmethod \n" +
        "    def classMethodTest(self):\n" +
        "        print(\"An example of a class method\")\n" +
        "    @staticmethod \n" +
        "    def staticMethodTest():\n" +
        "        print(\"This method does not have a `self` argument!\")\n" +
        "    def methodTest(self):\n" +
        "        print(\"This method is very classic, nothing fancy there.\")\n" +
        "    def __init__(self, number = 12, string = None):\n" +
        "        self.aNumber = number\n" +
        "        self.aString = string\n"
    
    public init?(_ myFunClass: MyFunClass) {
        guard let PySwift = PythonSwift.sharedInstance else { return nil }
        
        PySwift.execute(code: pythonCDecl)
        
        //let pClass = PySwift.__main__.attribute("PythonMyFunClass")
        //pClass.setAttribute("bar", value: __bridgeToPython("bitch"))
        //TESTMETH
        let pClass = PySwift.__main__.attribute("PythonMyFunClass")
        let pInstance = pClass.call(args: __bridgeToPython(myFunClass.aNumber), __bridgeToPython(myFunClass.aString))
        
        guard pInstance != PySwift.None else { return nil }
        
        super.init(ptr: pInstance.pythonObjPtr)
    }
    
    required public init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
    }
}

let testNumber = 12.7
let testString = "test23"

let sObj = MyFunClass(number: testNumber, string: testString)

guard let pObj = PythonMyFunClass(sObj) else { assertionFailure("Python bridge class initialization failed!") ; exit(1) }

let aNumber : PythonFloat = pObj.attribute("aNumber")
let aString : PythonString = pObj.attribute("aString")

print("Value `aNumber` is", testNumber, "in Swift and", __bridgeFromPython(aNumber) as Double!, "in the Python bridge class")
print("Value `aString` is", testString, "in Swift and", __bridgeFromPython(aString)!, "in the Python bridge class")

pObj.call("classMethodTest")
pObj.call("staticMethodTest")
pObj.call("methodTest")

////////////////////////////////////
////////////////////////////////////

var numargs : Int = CommandLine.arguments.count
let embNumargs : PyCFunction = {(self, args) -> PythonObjectPointer? in
    //this method is declared as METH_NOARGS (see below), therefore, the `args` parameter is NULL
    return Py_VaBuildValue("i", getVaList([numargs]))
}

func multiply(_ int : Int64, byInt : Int64) -> Int64 {
    return int * byInt
}

let multiply_trampoline : PyCFunction = {(rawSelf, args) -> PythonObjectPointer? in
    var firstArg: Int64 = 0
    var secondArg: Int64 = 0
    
    guard let _ : PythonObject = parseSelfAndArgs(rawSelf, args, "LL", &firstArg, &secondArg)
        else { return nil }
    
    let f : Int64 = multiply(firstArg, byInt: secondArg)
    return Py_VaBuildValue("L", getVaList([f]))
}

let describeListAsSwiftArray : PyCFunction = {(rawSelf, args) -> PythonObjectPointer? in
    var listArg: UnsafeMutablePointer<PyListObject> = prepareFor(PyListObject.self)
    
    guard let _ : PythonList = parseSelfAndArgs(rawSelf, args, "O", &listArg)
        else { return nil }
    //theoretically, returning nil without setting the Python exception (thru `PythonSwift.setPythonException`) should not be done, because then Python errors with "error return without exception set"
    //however, it is here deemed acceptable because if `parseSelfAndArgs` returns nil, it means that it has detected an error, and if it has done so, it has already set the Python exception
    
    
    guard let array : Array<Any> = __bridgeFromPython(PythonList(ptr: listArg))
        else {
            PythonSwift.setPythonException( PySwiftError.UnexpectedNone() ) //there we are the one having detected an error, therefore we have to set the Python exception ourselves
            return nil
    }
    
    let arrayDescription = __bridgeToPython(array.description)
    return Py_VaBuildValue("O", getVaList([arrayDescription.pythonObjPtr!]))
}

let embMethodList = [PythonMethod(name: "numargs", impl: embNumargs, flags: METH_NOARGS, docs: "Return the number of arguments received by the process."),
                     PythonMethod(name: "multiply", impl: multiply_trampoline, flags: METH_VARARGS, docs: "Test passing two `long` parameters and returning another."),
                     PythonMethod(name: "describeListAsSwiftArray", impl: describeListAsSwiftArray, flags: METH_VARARGS, docs: "Test passing and bridging a list.")]
let module = try PySwift.registerModule(named: "emb", methods: embMethodList)
PySwift.execute(code: "import emb; print('Number of arguments', emb.numargs())")
PySwift.execute(code: "print('Test1', emb.multiply(2, 3))")
PySwift.execute(code: "print('Test2', emb.describeListAsSwiftArray([1, 8]))")
PySwift.execute(code: "print('Test2bis', emb.describeListAsSwiftArray([[1, 8], 8]))")
PySwift.execute(code: "print('Test3', emb.describeListAsSwiftArray(None))")

////////////////////////////////////
////////////////////////////////////

public class Number {
    var integer : Int
    init(_ int : Int) {
        integer = int
    }
    
    func multiply(by: Int) -> Int {
        return integer * by
    }
    
    func multiply(by: Number) -> Int {
        return integer * by.integer
    }
}

extension Number : WrappableInPython {
    static let pythonTypeDefinition: UnsafeMutablePointer<PyTypeObject> = {
        let numbersMethodsDef = pythonMethodsDefinition
        
        let emb_NumberObjectInit : initproc = {(rawSelf, args, kwds) -> Int32 in
            var longParam: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
            defer {
                longParam.deallocate(capacity: 1)
            }
            
            let kwarray = ["number"] //NULL
            let retCode = withArrayOfCStrings(kwarray) {kwlist -> Int32 in
                let va_list: [CVarArg] = [longParam]
                return withVaList(va_list) { vaListPtr -> Int32 in
                    return PyArg_VaParseTupleAndKeywords(args, kwds, "L", UnsafeMutablePointer(mutating: kwlist), vaListPtr)
                }
            }
            guard retCode > 0 else { return -1 }
            
            let swiftNumberInstance = Number(Int(longParam.pointee))
            
            rawSelf!.withMemoryRebound(to: pyswift_PyObjWrappingSwift.self, capacity: 1) {numberObjPtr in
                numberObjPtr.pointee.wrapped_obj = bridgeRetained(obj: swiftNumberInstance)
            }
            
            return 0;
        }
        
        let numberTypeDef = buildPyTypeObject(named: "Number",
                                              inModule: "emb",
                                              sized: MemoryLayout<pyswift_PyObjWrappingSwift>.size,
                                              flagged: -1,
                                              documented: "Number objects",
                                              pyInit: emb_NumberObjectInit,
                                              methodList: numbersMethodsDef)
        return numberTypeDef
    }()
    
    static let pythonMethodsDefinition: UnsafeMutablePointer<PyMethodDef> = {
        let emb_NumberObject_multiply : PyCFunction = {(rawSelf, args) -> PythonObjectPointer? in
            var coco: UnsafeMutablePointer<Number> = prepareFor()
            
            guard let swiftInstance : Number = parseSelfAndArgs(rawSelf, args, "O", &coco)
                else { return nil }
            
            let otherInst : Number = finishFor(coco)
            
            let f : Int64 = Int64(swiftInstance.multiply(by: otherInst))
            
            return Py_VaBuildValue("L", getVaList([f]))
        }
        
        let emb_NumberObject_multiplyByInt : PyCFunction = {(rawSelf, args) -> PythonObjectPointer? in
            var firstArg: Int64 = 0
            
            guard let swiftInstance : Number = parseSelfAndArgs(rawSelf, args, "L", &firstArg)
                else { return nil }
            
            let f : Int64 = Int64(swiftInstance.multiply(by: Int(firstArg)))
            
            return Py_VaBuildValue("L", getVaList([f]))
        }
        
        let numberMethArray = [PythonMethod(name: "multiplyByInt", impl: emb_NumberObject_multiplyByInt, flags: METH_VARARGS, docs: "Multiplies the instance's wrapped long by the passed long."), PythonMethod(name: "multiply", impl: emb_NumberObject_multiply, flags: METH_VARARGS, docs: "Multiplies the receiver by the passed Number instance.")]
        let numberMethodsDef = buildMethodsDefArray(numberMethArray)
        return numberMethodsDef
    }()
    
    public class func getPythonTypeDefinition() -> UnsafeMutablePointer<PyTypeObject> {
        return pythonTypeDefinition
    }
    
    public class func getPythonMethods() -> UnsafeMutablePointer<PyMethodDef> {
        return pythonMethodsDefinition
    }
}

extension Number : BridgeableToPython {
    public func bridgeToPython() -> PythonBridge {
        return PythonNumber(self)
    }
}

public class PythonNumber : PythonObject, BridgeableFromPython {
    public init(_ number: Number) {
        let newPyObj = _PyObject_New(Number.getPythonTypeDefinition())
        
        newPyObj!.withMemoryRebound(to: pyswift_PyObjWrappingSwift.self, capacity: 1) {wrappingObjPtr in
            wrappingObjPtr.pointee.wrapped_obj = bridgeRetained(obj: number)
        }
        super.init(ptr: newPyObj!)
    }
    
    public required init(ptr: PythonObjectPointer?) {
        super.init(ptr: ptr ?? PyNone_Get())
        //check real python ob_type ?
    }
    
    public typealias SwiftMatchingType = Number
    public func typedBridgeFromPython() -> Number? {
        guard !self.isNone else { return nil }
        
        let pySelf = UnsafeMutableRawPointer(self.pythonObjPtr!).bindMemory(to: pyswift_PyObjWrappingSwift.self, capacity: 1).pointee
        let swSelf : Number = Unmanaged<Number>.fromOpaque(pySelf.wrapped_obj).takeRetainedValue()
        
        return swSelf
    }
}

let emb_NumberType = Number.getPythonTypeDefinition()
if (PyType_Ready(emb_NumberType) < 0) {
    exit(1)
}

emb_NumberType.withMemoryRebound(to: PyObject.self, capacity: 1) {objectTypePtr in
    Py_IncRef(objectTypePtr)
    PyModule_AddObject(module.pythonObjPtr!, "Number", objectTypePtr)
}

PySwift.execute(code: "print('Test4', emb.Number)")
PySwift.execute(code: "print('Test5', emb.Number(number=2).multiply(emb.Number(number=3)))")
PySwift.execute(code: "print('Test6', emb.Number(number=2).multiply(emb.Number(number=3), \"this string has nothing to do here\"))")
PySwift.execute(code: "print('Test7', emb.Number(number=2).multiplyByInt(3))")

let numberInstance = Number(4)
let numberInstanceBridged = numberInstance.bridgeToPython()
let cocorico = numberInstanceBridged.call("multiply", args: Number(12).bridgeToPython())
print(cocorico)

PythonBridgingManager.sharedInstance.registerBridge(type: emb_NumberType, to: PythonNumber.self)

guard let type = PythonBridgingManager.sharedInstance.getBridge(numberInstanceBridged.pythonObjPtr!) as? PythonBridge.Type
    else { abort() }

let pyBridge = type.init(ptr: numberInstanceBridged.pythonObjPtr!) as! UntypedBridgeableFromPython
let swValue : Any? = pyBridge.bridgeFromPython()

guard swValue! is Number else { assertionFailure("Dynamic bridging failed!") ; exit(1) }

