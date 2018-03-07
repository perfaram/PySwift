@import ObjectiveC.NSObjCRuntime;
@import CoreFoundation.CFBase;
@import Python;

typedef bool (^PyDictEnumeratorBlock)(PyObject*__nonnull key, PyObject*__nonnull value, Py_ssize_t pos);

PyObject*__nonnull PyNone_Get();

bool PyList_CheckIsList(PyObject*__nonnull obj);

bool PyDict_CheckIsDict(PyObject*__nonnull obj);
void PyDict_Enumerate(PyObject*__nonnull dict, PyDictEnumeratorBlock _Nonnull block);

PyObject*__nonnull PyList_Get_Item(PyObject*__nonnull seq, NSUInteger i);

PyObject*__nonnull PyTuple_Get_Item(PyObject*__nonnull seq, NSUInteger i);

PyObject*__nonnull PyBool_True();
PyObject*__nonnull PyBool_False();

NSString*__nonnull PyStringOrUnicode_Get_UTF8Buffer(PyObject*__nonnull uniObj);

PyObject*__nullable PyErr_GetObject();
