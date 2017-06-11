@import Python;
@import Foundation;

//#ifndef PYSWIFT_BRIDGE
extern const long Py_TPFLAGS_DEFAULT_value;

static PyTypeObject blankTypeObject = {
    PyVarObject_HEAD_INIT(NULL, 0) //expands to 1, NULL, 0,
    NULL,                      /* tp_name */
    0,                         /* tp_basicsize */
    0,                         /* tp_itemsize */
    0,                         /* tp_dealloc */
    0,                         /* tp_print */
    0,                         /* tp_getattr */
    0,                         /* tp_setattr */
    0,                         /* tp_compare */
    0,                         /* tp_repr */
    0,                         /* tp_as_number */
    0,                         /* tp_as_sequence */
    0,                         /* tp_as_mapping */
    0,                         /* tp_hash */
    0,                         /* tp_call */
    0,                         /* tp_str */
    0,                         /* tp_getattro */
    0,                         /* tp_setattro */
    0,                         /* tp_as_buffer */
    Py_TPFLAGS_DEFAULT,        /* tp_flags */
    NULL,           /* tp_doc */
};

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    PyObject_HEAD
    /* Type-specific fields go here. */
    void* wrapped_obj;
} pyswift_PyObjWrappingSwift;
NS_ASSUME_NONNULL_END

@interface PythonMethod : NSObject
@property (readonly, nonnull) NSString* name;
@property (readonly, nonnull) PyCFunction impl;
@property (readonly) int flags;
@property (readonly, nullable) NSString* docs;

-(instancetype __nonnull)initWithName:(NSString*_Nonnull)name impl:(PyCFunction _Nonnull)impl flags:(int)flags docs:(NSString*_Nullable)docs;
@end

PyMethodDef*_Nonnull buildMethodsDefArray(NSArray<PythonMethod *>*_Nonnull array);
//#define PYSWIFT_BRIDGE
//#endif
