#import "include/pyswift_macros.h"
PyObject*__nonnull PyNone_Get() {
    Py_RETURN_NONE;
}

bool PyList_CheckIsList(PyObject*__nonnull obj) {
    return ((((((PyObject*)(obj))->ob_type))->tp_flags & (Py_TPFLAGS_LIST_SUBCLASS)) != 0);
}

PyObject*__nonnull PyList_Get_Item(PyObject*__nonnull seq, NSUInteger i) {
    return PyList_GET_ITEM(seq, i);
    //(((PyListObject *)(obj))->ob_item[i]); //PyList_GET_ITEM
}

PyObject*__nonnull PyTuple_Get_Item(PyObject*__nonnull seq, NSUInteger i) {
    return PyTuple_GET_ITEM(seq, i);
    //(((PyTupleObject *)(obj))->ob_item[i]); //PyTuple_GET_ITEM
}
