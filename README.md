# fyx-autodocumentation

This action generates in-code API documentation skeleton for R, Python, and Rust.

## Example Usage
```
uses: PharaohCola13/fyx-autodocumentation@main
env:
   FYX_USERNAME: PharaohCola13
   FYX_EMAIL: academic@sriley.dev
```

## Test case

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
    return out
```
