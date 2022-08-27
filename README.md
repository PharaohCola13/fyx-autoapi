# fyx-autodoc

This action generates in-code API documentation skeleton for R, Python, and Rust.

## The Fyx Framework

**File Level Tags**
Tag | Description
-----|--------------------------
file | the file name 
synopsis | description of the file's purpose 
author | the author with email in the form AuthorName \<AuthorEmail\>

**Function Level Tags**

Tag | Description
-----|--------------------------
detail | description of the function 
param (type) arg (default) | the description of the argument
return (type) | Information regarding the output of the function
test-method | What type of assertion will be used in the unit tests

## Example Usage
```
uses: PharaohCola13/fyx-autodocumentation@main
with:
   dir: ./src
   type: all
env:
   FYX_USERNAME: PharaohCola13
   FYX_EMAIL: academic@sriley.dev
```

### Inputs

Argument | Description
---------|---------------
wdir | 

## Test case (test.py)

Simple Python file
```Python
def test(arg6, arg7=1, arg8="test1"):
    return out
```
Result
```Python
#> file:  ./test.py
#> synopsis: 
#> author: PharaohCola13 <academic@sriley.dev>
def test(arg6, arg7=1, arg8="test1"):
#> detail: 
#> param (type) arg6:
#> param (type) arg7 (1):
#> param (type) arg8 (test1):
#> return (type): 
#> test-method: 
    return out
```

## Test case (test.r)

Simple Python file
```R
test1 <- function(arg1, arg2="test2"){
    return(args)
}

test2 <- function(arg3, arg4){
   return(args)
}
```
Result
```R
#> file:  ./test.r
#> synopsis: 
#> author: PharaohCola13 <academic@sriley.dev>
test1 <- function(arg1, arg2="test2"){
#> detail: 
#> param (type) arg1:
#> param (type) arg2 (test2):
#> return (type):
#> test-method:
    return(args)
}

test2 <- function(arg3, arg4){
#> detail: 
#> param (type) arg3:
#> param (type) arg4:
#> return (type): 
   return(args)
}
```

## Test case (test.rs)

Simple Rust file
```Rust
fn test -> function(arg5:u32, arg6:i16){
    return out
}


fn test2 -> function(arg5:u32, arg10:i8){
}
```
Result
```Rust
//> file:  ./test.rs
//> synopsis: 
//> author: PharaohCola13 <academic@sriley.dev>
fn test -> function(arg5:u32, arg6:i16){
//> detail: 
//> param (u32) arg5:
//> param (i16) arg6:
//> return (type):
//> test-method:
    return out
}


fn test2 -> function(arg5:u32, arg10:i8){
//> detail: 
//> param (u32) arg5:
//> param (i8) arg10:
//> return (type): 
//> test-method:

}
```
