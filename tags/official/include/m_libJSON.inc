{$IFNDEF MIM_LIBJSON}
{$DEFINE MIM_LIBJSON}

type
 PJSONNODE = ^JSONNODE;
 JSONNODE = pointer; 
 TJSONNODE_ITERATOR = pointer; //^^JSONNODE; // typedef JSONNODE** JSONNODE_ITERATOR;

// This function get the service interface for direct calling
// wParam=(WPARAM)(LPJSONSERVICEINTERFACE)
// lParam=0
// Return value ALWAYS 0

type
  PJSONSERVICEINTERFACE = ^TJSONSERVICEINTERFACE;
  TJSONSERVICEINTERFACE = record
    free              : procedure (str:pointer);cdecl;
    delete_           : procedure (node:PJSONNODE);cdecl;
    free_all          : procedure ;cdecl;
    delete_all        : procedure ;cdecl;
    parse             : function (json:PAnsiChar):PJSONNODE;cdecl;
    strip_white_space : function (json:PAnsiChar):PAnsiChar;cdecl;
    validate          : function (json:PAnsiChar):PJSONNODE;cdecl;

    new_a     : function (name:PAnsiChar; value:PAnsiChar):PJSONNODE;cdecl;
    new_i     : function (name:PAnsiChar; value:long):PJSONNODE;cdecl;
    new_f     : function (name:PAnsiChar; value:double):PJSONNODE;cdecl;
    new_b     : function (name:PAnsiChar; value:int):PJSONNODE;cdecl;
    new_      : function (_type:char):PJSONNODE;cdecl;

    copy      : function (orig:PJSONNODE):PJSONNODE;cdecl;
    duplicate : function (orig:PJSONNODE):PJSONNODE;cdecl;

    set_a     : procedure (node:PJSONNODE; value:PAnsiChar);cdecl;
    set_i     : procedure (node:PJSONNODE; value:long);cdecl;
    set_f     : procedure (node:PJSONNODE; value:double);cdecl;
    set_b     : procedure (node:PJSONNODE; value:int);cdecl;
    set_n     : procedure (node:PJSONNODE; orig:PJSONNODE);cdecl;

    _type       : function (node:PJSONNODE):char;cdecl;
    size        : function (node:PJSONNODE):uint;cdecl;
    empty       : function (node:PJSONNODE):int;cdecl;
    name        : function (node:PJSONNODE):PAnsiChar;cdecl;
    get_comment : function (node:PJSONNODE):PAnsiChar;cdecl;

    as_string : function (node:PJSONNODE):PAnsiChar;cdecl;
    as_int    : function (node:PJSONNODE):long;cdecl;
    as_float  : function (node:PJSONNODE):double;cdecl;
    as_bool   : function (node:PJSONNODE):int;cdecl;
    as_node   : function (node:PJSONNODE):PJSONNODE;cdecl;
    as_array  : function (node:PJSONNODE):PJSONNODE;cdecl;
    as_binary : function (node:PJSONNODE; size:Pulong):pointer;cdecl;

    write           : function (node:PJSONNODE):PAnsiChar;cdecl;
    write_formatted : function (node:PJSONNODE):PAnsiChar;cdecl;
    set_name        : procedure (node:PJSONNODE; name:PAnsiChar);cdecl;
    set_comment     : procedure (node:PJSONNODE; comment:PAnsiChar);cdecl;
    clear           : procedure (node:PJSONNODE);cdecl;
    nullify         : procedure (node:PJSONNODE);cdecl;
    swap            : procedure (node:PJSONNODE; node2:PJSONNODE);cdecl;
    merge           : procedure (node:PJSONNODE; node2:PJSONNODE);cdecl;
    preparse        : procedure (node:PJSONNODE);cdecl;
    set_binary      : procedure (node:PJSONNODE; data:pointer; length:ulong);cdecl;
    cast            : procedure (node:PJSONNODE; _type:AnsiChar);cdecl;
    reserve         : procedure (node:PJSONNODE; siz:uint);cdecl;
    at              : function (node:PJSONNODE; pos:uint):PJSONNODE;cdecl;
    get             : function (node:PJSONNODE; name:PAnsiChar):PJSONNODE;cdecl;
    get_nocase      : function (node:PJSONNODE; name:PAnsiChar):PJSONNODE;cdecl;
    pop_back_nocase : function (node:PJSONNODE; name:PAnsiChar):PJSONNODE;cdecl;
    push_back       : procedure (node:PJSONNODE; node2:PJSONNODE);cdecl;
    pop_back_at     : function (node:PJSONNODE; pos:uint):PJSONNODE;cdecl;
    pop_back        : function (node:PJSONNODE; name:PAnsiChar):PJSONNODE;cdecl;
    find            : function (node:PJSONNODE; name:PAnsiChar):TJSONNODE_ITERATOR;cdecl;
    find_nocase     : function (node:PJSONNODE; name:PAnsiChar):TJSONNODE_ITERATOR;cdecl;
    erase           : function (node:PJSONNODE; it:TJSONNODE_ITERATOR):TJSONNODE_ITERATOR;cdecl;
    erase_multi     : function (node:PJSONNODE; start:TJSONNODE_ITERATOR;
                                _end:TJSONNODE_ITERATOR):TJSONNODE_ITERATOR;cdecl;
    insert          : function (node:PJSONNODE; it:TJSONNODE_ITERATOR; node2:PJSONNODE):TJSONNODE_ITERATOR;cdecl;
    insert_multi    : function (node:PJSONNODE; it:TJSONNODE_ITERATOR; start:TJSONNODE_ITERATOR;
                                _end:TJSONNODE_ITERATOR):TJSONNODE_ITERATOR;cdecl;

    _begin : function (node:PJSONNODE):TJSONNODE_ITERATOR;cdecl;
    _end   : function (node:PJSONNODE):TJSONNODE_ITERATOR;cdecl;
    equal  : function (node:PJSONNODE; node2:PJSONNODE):int;cdecl;
  end;

const
  MS_JSON_GETINTERFACE:PAnsiChar = 'JSON/GetInterface';

// This function removes the memory allocated by various functions that return strings,
// such as MS_JSON_AS_*, json_write...
// wParam=(WPARAM)(LPVOID)pVoid
// lParam=0
// Return value ALWAYS 0
  MS_JSON_FREE:PAnsiChar = 'JSON/Free';

// Delete specified node and all its children
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Return value ALWAYS 0
  MS_JSON_DELETE:PAnsiChar = 'JSON/Delete';

// <!-- These functions are only available if JSON_MEMORY_MANAGE is defined on building
(*
// This function removes all of the memory that libjson has allocated for strings and binary.
// This allows for bulk frees and garbage collection.
// wParam=lParam=0
// Return value ALWAYS 0
  MS_JSON_FREE_ALL:PAnsiChar = 'JSON/FreeAll';

// Destructs the JSONNode object and cleans itself up.
// wParam=lParam=0
// Return value ALWAYS 0
  MS_JSON_DELETE_ALL:PAnsiChar = 'JSON/DeleteAll';
*)
// -->

// This function parses JSON text and returns you a HANDLE which is the root node of the text 
// that you just passed it.  If bad JSON is sent to this method it may return NULL.
// wParam=(WPARAM)(LPCSTR)szJSON
// lParam=0
// Returns a HANDLE on success, NULL on failure
// * Remember to free the handle with MS_JSON_DELETE
  MS_JSON_PARSE:PAnsiChar = 'JSON/Parse';

// This function removes anything that the JSON standard defines as white space, 
// including extra tabs, spaces, formatting, and comments.  This makes this function useful 
// for compressing json that needs to be stored or sent over a network.
// wParam=(WPARAM)(LPCSTR)szJSON
// lParam=0
// Returns a newly allocated valid JSON that is free of all white space
// * Remember to free the string with MS_JSON_FREE
  MS_JSON_STRIP_WHITE_SPACE:PAnsiChar = 'JSON/StripWhiteSpace';


// <!-- These functions are only available if JSON_VALIDATE is defined on building
(*
// This function validates the text by parsing it completely and looking for anything that is 
// malformed.  If bad JSON is sent to this method it will throw a std::invalid_argument exception, 
// otherwise it returns the root node of the text.
// wParam=(WPARAM)(LPCSTR)szJSON
// lParam=0
// Returns a HANDLE on success
// * Remember to free the handle with MS_JSON_DELETE
  MS_JSON_VALIDATE:PAnsiChar = 'JSON/Validate';
*)
// -->

// This function creates a string node with the name and value specified.  
// wParam=(WPARAM)(LPCSTR)szName
// lParam=(LPARAM)(LPCSTR)szValue
// Returns a newly allocated node
// You must (*delete the resulting node or attach it to something as a child.
  MS_JSON_NEW_STRING:PAnsiChar = 'JSON/NewA';

// This function creates a integer node with the name and value specified.  
// wParam=(WPARAM)(LPCSTR)szName
// lParam=(LPARAM)(long)lValue
// Returns a newly allocated node
// You must (*delete the resulting node or attach it to something as a child.
// Warning: The value IS SIGNED, for unsigned use MS_JSON_NEW_FLOAT instead.
  MS_JSON_NEW_INTEGER:PAnsiChar = 'JSON/NewI';

// This function creates a floating point node with the name and value specified.  
// wParam=(WPARAM)(LPCSTR)szName
// lParam=(LPARAM)(float)fValue
// Returns a newly allocated node
// You must (*delete the resulting node or attach it to something as a child.
  MS_JSON_NEW_FLOAT:PAnsiChar = 'JSON/NewF';

// This function creates a boolean node with the name and value specified.  
// wParam=(WPARAM)(LPCSTR)szName
// lParam=(LPARAM)(int)iValue
// Returns a newly allocated node
// You must (*delete the resulting node or attach it to something as a child.
  MS_JSON_NEW_BOOLEAN:PAnsiChar = 'JSON/NewB';

// This function creates an empty node of the specified type.  
// This would normally be used to start serializing something or writing a configuration file.
// wParam=(WPARAM)(char)cType
// lParam=0
// Returns a newly allocated node
// You must (*delete the resulting node or attach it to something as a child.
  JSON_NULL   = #0;
  JSON_STRING = #1;
  JSON_NUMBER = #2;
  JSON_BOOL   = #3;
  JSON_ARRAY  = #4;
  JSON_NODE   = #5;

  MS_JSON_NEW:PAnsiChar = 'JSON/New';

// This function copies a JSONNODE and returns the new copy.  
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns an exact copy of the node parameter
  MS_JSON_COPY:PAnsiChar = 'JSON/Copy';

// Constructs a JSONNODE object, by copying the contents of JSONNODE.  
// This is different from the MS_JSON_COPY because it makes a literal copy, 
// not reference counting. 
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a HANDLE that is a new copy of the original node.
  MS_JSON_DUPLICATE:PAnsiChar = 'JSON/Duplicate';

// Sets the string value of the JSONNODE.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szValue
// Return value ALWAYS 0
  MS_JSON_SET_STRING:PAnsiChar = 'JSON/SetA';

// Sets the integer value of the JSONNODE.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(long)lValue
// Return value ALWAYS 0
// Warning: The value IS SIGNED, for unsigned use MS_JSON_SET_FLOAT instead.
  MS_JSON_SET_INTEGER:PAnsiChar = 'JSON/SetI';

// Sets the floating point value of the JSONNODE.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(float)fValue
// Return value ALWAYS 0
  MS_JSON_SET_FLOAT:PAnsiChar = 'JSON/SetF';

// Sets the boolean value of the JSONNODE.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(int)iValue
// Return value ALWAYS 0
  MS_JSON_SET_BOOLEAN:PAnsiChar = 'JSON/SetB';

// Sets the value of the JSONNODE to the value of the other, 
// usually through fast and simple reference counting.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(HANDLE)hValueNode
// Return value ALWAYS 0
  MS_JSON_SET_NODE:PAnsiChar = 'JSON/SetN';

// Returns the type of the JSONNODE.
// usually through fast and simple reference counting.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns value of JSON_* (See MS_JSON_NEW)
  MS_JSON_TYPE:PAnsiChar = 'JSON/Type';

// Returns the number of children that the node has.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns the number of children
// This should be zero for anything other than JSON_ARRAY or JSON_NODE, 
// but this is only guaranteed with the JSON_SAFE option turned on (by default).
// This is because casting may or may not purge the children.
  MS_JSON_SIZE:PAnsiChar = 'JSON/Size';

// Returns whether or not the node has any children.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns 0 if the node is empty, nonzero if not
// If the node is not of JSON_NODE or JSON_ARRAY it will invariably return true.
  MS_JSON_EMPTY:PAnsiChar = 'JSON/Empty';

// Returns the name of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a newly allocated string.
// If there is no name, then it returns a blank string.
  MS_JSON_NAME:PAnsiChar = 'JSON/Name';

// <!-- These functions are only available if JSON_COMMENTS is defined on building
(*
// Returns the comment attached to the node
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a newly allocated string.
  MS_JSON_COMMENT:PAnsiChar = 'JSON/Comment';

// Sets the comment that will be associated with the JSONNode.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szComment
// Return value ALWAYS 0
  MS_JSON_SET_COMMENT:PAnsiChar = 'JSON/SetComment';
*)
// -->

// Returns the string representation of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a newly allocated string representation of the node.
// The return value may be different depending on the type of the node
// JSON_NULL: "" or "null" depending on how it was created
// JSON_STRING: The unescaped string value
// JSON_NUMBER: The number in string form (may be in scientific notation)
// JSON_BOOL: "true" or "false"
// JSON_ARRAY: ""
// JSON_NODE: ""
  MS_JSON_AS_STRING:PAnsiChar = 'JSON/AsString';

// Returns the integer representation of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns the integer representation of the node.
// The return value may be different depending on the type of the node
// JSON_NULL: 0
// JSON_STRING: Undefined
// JSON_NUMBER: Truncated Value
// JSON_BOOL: 1 if true, 0 if false
// JSON_ARRAY: Undefined
// JSON_NODE: Undefined
// Warning: The value IS SIGNED, for unsigned use MS_JSON_AS_FLOAT instead.
// If the value is actually a floating point value, it will continue on ahead 
// and simply truncate the value.  So 15.9 will be returned as 15.
  MS_JSON_AS_INTEGER:PAnsiChar = 'JSON/AsInt';

// Returns the floating point representation of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns the floating point representation of the node.
// The return value may be different depending on the type of the node
// JSON_NULL: 0.0
// JSON_STRING: Undefined
// JSON_NUMBER: Value
// JSON_BOOL: 1.0 if true, 0.0 if false
// JSON_ARRAY: Undefined
// JSON_NODE: Undefined
  MS_JSON_AS_FLOAT:PAnsiChar = 'JSON/AsFloat';

// Returns the boolean representation of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns the boolean representation of the node.
// The return value may be different depending on the type of the node
// JSON_NULL: 0.0
// JSON_STRING: Undefined
// JSON_NUMBER: Value == 0.0
// JSON_BOOL: Value
// JSON_ARRAY: Undefined
// JSON_NODE: Undefined
  MS_JSON_AS_BOOLEAN:PAnsiChar = 'JSON/AsBool';

// Returns the boolean representation of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a HANDLE of the node.
// The return value may be different depending on the type of the node
// JSON_NULL: Empty node
// JSON_STRING: Empty node
// JSON_NUMBER: Empty node
// JSON_BOOL: Empty node
// JSON_ARRAY: Array converted to a node
// JSON_NODE: A copy of the node
// For anything other than node and array, it simply returns an 
// empty node.  If the caller is an array, it will convert it to a node.
// This command creates a new JSONNODE that has to be deleted or attached to a parent.
  MS_JSON_AS_NODE:PAnsiChar = 'JSON/AsNode';

// Returns the array representation of the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a HANDLE of the node.
// The return value may be different depending on the type of the node
// JSON_NULL: Empty node
// JSON_STRING: Empty node
// JSON_NUMBER: Empty node
// JSON_BOOL: Empty node
// JSON_ARRAY: A copy of the array
// JSON_NODE: An array of the children
// For anything other than node and array, it simply returns an 
// empty array.  If the caller is an node, it will convert it to an array by stripping 
// all of the names of each child.
// This command creates a new JSONNODE that has to be deleted or attached to a parent.
  MS_JSON_AS_ARRAY:PAnsiChar = 'JSON/AsArray';

// <!-- These functions are only available if JSON_BINARY is defined on building
(*
// Returns the binary value that was part of this node. 
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPDWORD)pdwSize
// Returns a Base64 decoded binary data as std::string.
// The return value may be different depending on the type of the node
// JSON_NULL: Undefined
// JSON_STRING: The binary data from the decoded Base64
// JSON_NUMBER: Undefined
// JSON_BOOL: Undefined
// JSON_ARRAY: Undefined
// JSON_NODE: Undefined
// It returns it as a std::string, you can use the data() function to retrieve it in binary form.
// This allows you to use size() to know how large the binary data is.
// pdwSize points to a DWORD to receive how many bytes the data is
  MS_JSON_AS_BINARY:PAnsiChar = 'JSON/AsBinary';
*)
// -->

// Returns JSON text, with no white space or comments.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a JSON text of the node being written.
// Remember to free the return value with MS_JSON_FREE
// Designed to create JSON that is very small, and therefore, faster to send between 
// servers or write to a disk. The flipside is that it's nearly impossible to read by human eyes.
// Only root nodes (JSON_NODE and JSON_ARRAYs) are meant to be written, 
// all others will return a blank string.
  MS_JSON_WRITE:PAnsiChar = 'JSON/Write';

// Returns JSON text that has been indented and prettied up so that it can be easily 
// read and modified by humans.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Returns a JSON text of the node being written.
// Remember to free the return value with MS_JSON_FREE
// Only root nodes (JSON_NODE and JSON_ARRAYs) are meant to be written, 
// all others will return a blank string.
  MS_JSON_WRITE_FORMATTED:PAnsiChar = 'JSON/WriteFormatted';

// Sets the name of the JSONNode.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szName
// Return value ALWAYS 0
  MS_JSON_SET_NAME:PAnsiChar = 'JSON/SetName';

// Clears all children from the node.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Return value ALWAYS 0
  MS_JSON_CLEAR:PAnsiChar = 'JSON/Clear';

// Nulls out the node
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Return value ALWAYS 0
  MS_JSON_NULLIFY:PAnsiChar = 'JSON/Nullify';

// Swaps the contents of two nodes. 
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(WPARAM)(HANDLE)hCode2
// Return value ALWAYS 0
// This is very fast because JSONNODE is just a wrapper around an 
// internal structure, so it simply swaps pointers to those structures.
  MS_JSON_SWAP:PAnsiChar = 'JSON/Swap';

// Merge the contents of nodes
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(WPARAM)(HANDLE)hCode2
// Return value ALWAYS 0
// It's possible that you may end up with multiple copies of the same node, 
// through duplication and such.  To save space, you might want to merge the 
// internal reference counted structure.
  MS_JSON_MERGE:PAnsiChar = 'JSON/Merge';

// Preparse the json
// wParam=(WPARAM)(HANDLE)hNode
// lParam=0
// Return value ALWAYS 0
// libjson's lazy parsing makes parsing JSON that is not entirely used very fast, 
// but sometimes you want to parse it all at once, making the next reads a little faster
  MS_JSON_PREPARSE:PAnsiChar = 'JSON/Preparse';

// (*set_binary not reflected as it requires 3 parameters
(*
#ifdef JSON_BINARY
 void (*set_binary(JSONNODE * node, const void * data, unsigned long length);
#endif
*)

// Will change the node to a different type and do any conversions necessary.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(char)cType
// Return value ALWAYS 0
// Value of cType refer to MS_JSON_NEW
  MS_JSON_CAST:PAnsiChar = 'JSON/Cast';

// This function reserves children space, this makes the program faster and use less memory 
// as it doesn't have to keep allocating new memory when it runs out.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(int)iSize
// Return value ALWAYS 0
// Value of cType refer to MS_JSON_NEW
  MS_JSON_RESERVE:PAnsiChar = 'JSON/Reserve';

// This will give you a reference to a child node at a specific location.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(int)iPos
// Returns the HANDLE to the iPos' node of hNode
// This is a safe function and will return zero if you go out of bounds.
// The returned value is still a child, so do not try and delete the results.
  MS_JSON_AT:PAnsiChar = 'JSON/At';

// This will give you a reference to a child node by its name.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szName
// Returns the HANDLE of the child named szName
// This is a safe function and will return zero if that child does not exist.
// The returned value is still a child, so do not try and delete the results.
  MS_JSON_GET:PAnsiChar = 'JSON/Get';

// <!-- These functions are only available if JSON_CASE_INSENSITIVE_FUNCTIONS is defined on building
(*
// This will give you a reference to a child node by its name.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szName
// Returns the HANDLE of the child named szName
// This is a safe function and will return zero if that child does not exist.
// The returned value is still a child, so do not try and delete the results.
  MS_JSON_GET_NOCASE:PAnsiChar = 'JSON/GetNocase';

// This will give remove a JSONNODE from it's parent and return it to you.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szName
// Returns the HANDLE of the child named szName
// Because it's removed from the parent, you must delete it yourself.
  MS_JSON_POP_BACK_NOCASE:PAnsiChar = 'JSON/PopBackNocase';
*)
// -->

// This function pushes a new child node on the back of the child list.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(HANDLE)hNode2
// Return value ALWAYS 0
// This method copies the child, so altering the parameter later will not affect the one in the children.  
// The child is then managed, so do not try and delete it later.
  MS_JSON_PUSH_BACK:PAnsiChar = 'JSON/PushBack';

// This will give remove a JSONNODE from it's parent and return it to you.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(int)iPos
// Returns the HANDLE of the child named szName
// Because it's removed from the parent, you must delete it yourself.
  MS_JSON_POP_BACK_AT:PAnsiChar = 'JSON/PopBackAt';

// This will give remove a JSONNODE from it's parent and return it to you.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(LPCSTR)szName
// Returns the HANDLE of the child named szName
// Because it's removed from the parent, you must delete it yourself.
  MS_JSON_POP_BACK:PAnsiChar = 'JSON/PopBack';
(*
// functions with JSON_ITERATORS not reflected
		  #ifdef JSON_ITERATORS
			 JSONNODE_ITERATOR (*find(JSONNODE * node, const char * name);
			 #ifdef JSON_CASE_INSENSITIVE_FUNCTIONS
				JSONNODE_ITERATOR (*find_nocase(JSONNODE * node, const char * name);
			 #endif
			 JSONNODE_ITERATOR (*erase(JSONNODE * node, JSONNODE_ITERATOR it);
			 JSONNODE_ITERATOR (*erase_multi(JSONNODE * node, JSONNODE_ITERATOR start, JSONNODE_ITERATOR end);
			 JSONNODE_ITERATOR (*insert(JSONNODE * node, JSONNODE_ITERATOR it, JSONNODE * node2);
			 JSONNODE_ITERATOR (*insert_multi(JSONNODE * node, JSONNODE_ITERATOR it, JSONNODE_ITERATOR start, JSONNODE_ITERATOR end);
	 
			 //iterator functions
			 JSONNODE_ITERATOR (*begin(JSONNODE * node);
			 JSONNODE_ITERATOR (*end(JSONNODE * node);
		  #endif
*)
// Checks if the value held within the nodes are equal.
// wParam=(WPARAM)(HANDLE)hNode
// lParam=(LPARAM)(HANDLE)hNode2
// Returns 0 if not equal, nonzero otherwise
// This ignores things like comments, but for JSON_NODE and JSON_ARRAYs, 
// this is a deep comparison, checking each child too.
  MS_JSON_EQUAL:PAnsiChar = 'JSON/Equal';

{$ENDIF}
