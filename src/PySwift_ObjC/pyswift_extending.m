#import "include/pyswift_extending.h"

const long Py_TPFLAGS_DEFAULT_value = Py_TPFLAGS_DEFAULT;

PyMethodDef* buildMethodsDefArray(NSArray<PythonMethod *>* array) {
    NSUInteger count = array.count;
    PyMethodDef* meth_array = calloc((count + 1), sizeof(PyMethodDef));
    
    for (int i = 0; i < count; i++) {
        PyMethodDef* method = &meth_array[i];
        method->ml_name = array[i].name.UTF8String;
        method->ml_meth = array[i].impl;
        method->ml_flags = array[i].flags;
        if (array[i].docs)
            method->ml_doc = array[i].docs.UTF8String;
        else
            method->ml_doc = array[i].name.UTF8String;
    }
    PyMethodDef* sentinel = &meth_array[count];
    sentinel->ml_name = NULL;
    sentinel->ml_meth = NULL;
    sentinel->ml_flags = 0;
    sentinel->ml_doc = NULL;
    return meth_array;
}

@implementation PythonMethod
-(instancetype)initWithName:(NSString*)name impl:(PyCFunction)impl flags:(int)flags docs:(NSString*)docs {
    self = [super init];
    _name = name;
    _impl = impl;
    _flags = flags;
    _docs = docs;
    return self;
}
@end
