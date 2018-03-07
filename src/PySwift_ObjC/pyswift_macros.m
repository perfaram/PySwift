#import "include/pyswift_macros.h"
@import Foundation.NSString;
PyObject*__nonnull PyNone_Get() {
    Py_RETURN_NONE;
}

bool PyList_CheckIsList(PyObject*__nonnull obj) {
    return ((((((PyObject*)(obj))->ob_type))->tp_flags & (Py_TPFLAGS_LIST_SUBCLASS)) != 0);
}

bool PyDict_CheckIsDict(PyObject*__nonnull obj) {
    return PyDict_Check(obj);
}

void PyDict_Enumerate(PyObject*__nonnull dict, PyDictEnumeratorBlock block) {
    PyObject *key, *value;
    Py_ssize_t pos = 0;
    
    while (PyDict_Next(dict, &pos, &key, &value)) {
        bool shouldContinue = block(key, value, pos);
        if (!shouldContinue) break;
    }
}

PyObject*__nonnull PyList_Get_Item(PyObject*__nonnull seq, NSUInteger i) {
    return PyList_GET_ITEM(seq, i);
    //(((PyListObject *)(obj))->ob_item[i]); //PyList_GET_ITEM
}

PyObject*__nonnull PyTuple_Get_Item(PyObject*__nonnull seq, NSUInteger i) {
    return PyTuple_GET_ITEM(seq, i);
    //(((PyTupleObject *)(obj))->ob_item[i]); //PyTuple_GET_ITEM
}

PyObject*__nonnull PyBool_True() {
    return Py_True;
}

PyObject*__nonnull PyBool_False() {
    return Py_False;
}

NSString*__nonnull PyStringOrUnicode_Get_UTF8Buffer(PyObject*__nonnull string) {
    NSString* ret = nil;
    
    PyObject* utf8 = PyUnicode_AsUTF8String(string);
    if (!utf8) {
        PyErr_Clear();
        PyObject* ascii_mystring = PyUnicode_AsASCIIString(string);
        ret = [[NSString alloc]
               initWithBytes:PyBytes_AsString(ascii_mystring)
               length:(NSUInteger)PyBytes_GET_SIZE(ascii_mystring)
               encoding:NSUTF8StringEncoding];
        Py_DECREF(ascii_mystring);
    } else {
        ret = [[NSString alloc]
                      initWithBytes:PyBytes_AS_STRING(utf8)
                      length:(NSUInteger)PyBytes_GET_SIZE(utf8)
                      encoding:NSUTF8StringEncoding];
        Py_DECREF(utf8);
    }
    return ret;
}

PyObject*__nullable PyErr_GetObject() {
    PyObject* errOccurred = PyErr_Occurred();
    if (errOccurred == NULL)
        return nil;
    PyThreadState *tstate = PyThreadState_GET();
    PyObject *value = tstate->curexc_value;
    
    if (!PyExceptionInstance_Check(value))
        return nil;
    
    value = ((PyBaseExceptionObject*)value)->args;
    Py_XINCREF(value);
    return value;
}
