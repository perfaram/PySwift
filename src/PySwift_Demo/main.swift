import PySwift
import Python
import PySwift_None

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

var keywordArgs : [String : PythonBridgeable] = ["times" : 3, "surname" : "Bond"]

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
