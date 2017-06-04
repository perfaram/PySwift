import PySwift
import Python

print("First things first : you absolutely have to initialize the Python interpreter before anything else.")
initPython() //required before anything else

////////////////////////////////////
////////////////////////////////////

print("\nWhy not try a few simple things as a warm-up ?")

let addStr = eval("1 + 1")
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
evalStatement(pythonComparator)
let compareResult = call("compare", args:
    helloPythonInitializer,
                         helloPythonStringLiteral,
                         helloPythonBridgingProtocolExtension,
                         helloPythonBridgingFreeFloatingFunc)
print("Comparing objects in Python :", compareResult)

////////////////////////////////////
////////////////////////////////////

let text = "a text"
print("\nWe are now going to print `\(text)` in 2 differents ways")

evalStatement("print '\(text)'") //one way

_ = call("print", args: text.bridgeToPython()) //another way

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

guard importModule(named: "random") else { print("Couldn't import the module named `random`, exiting !"); exit(1) } //like Python's "import random"

let defChooseFile = "def chooseFile(arr):\n" +
"    return random.choice(arr)"
evalStatement(defChooseFile) //load the code in the interpreter

let moutains: PythonList = ["Everest", "Kilimanjaro", "La Tournette", "Denali"]
let chose = call("chooseFile", args: moutains)
print(chose)

////////////////////////////////////
////////////////////////////////////

print("\nLast one : a showcase of the ability to mutate Python objects from Swift – for example, by changing an ivar.")

let defFoo = "class Foo:\n" +
             "    def __init__(self):\n" +
             "        print('Instantiating an instance of Foo, in Python...')\n" +
             "        self.bar = 'I am the `bar` ivar of Foo'"

evalStatement(defFoo)

let foo = eval("Foo()")
let bar = foo.attr("bar")
print("foo.bar =", bar)

let newBarVal:PythonString = "I'm the new bar"
print("Setting a new bar to our instance of Foo, from Swift...")
foo.setAttr("bar", value: newBarVal)
let newBar = foo.attr("bar")
print("foo.bar =", newBar)

////////////////////////////////////
////////////////////////////////////

print("\nOne past last : named arguments")

let sayHelloFn = "def sayHello(name, surname = \"\", times = 1):\n" +
"    for i in range(times):" +
"        print(\"Hello, \" + name + \" \" + surname + \"!\")"
evalStatement(sayHelloFn) //load the code in the interpreter

let keywordArgs : Dictionary<String, PythonBridge> = ["times" : 3.bridgeToPython(), "surname" : "Bond".bridgeToPython()]
let positionalArgs = ["James".bridgeToPython()]
call("sayHello", positionalArgs: positionalArgs, keywordArgs: keywordArgs)
