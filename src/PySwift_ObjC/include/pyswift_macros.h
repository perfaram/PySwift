@import ObjectiveC.NSObjCRuntime;
@import Python;

PyObject*__nonnull PyNone_Get();

bool PyList_CheckIsList(PyObject*__nonnull obj);

PyObject*__nonnull PyList_Get_Item(PyObject*__nonnull seq, NSUInteger i);

PyObject*__nonnull PyTuple_Get_Item(PyObject*__nonnull seq, NSUInteger i);

PyObject*__nonnull PyBool_True();
PyObject*__nonnull PyBool_False();
