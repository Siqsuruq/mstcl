# mstcl
MapServer Mapfile parser class, written in Tcl/NX

## Basic Usage
First you need to include source,and create new Mapfile object. In the future I will include tcl package version:
```
source mstcl.tcl
Mapfile create map -name map.map -path ./
```
This will create __::map__ object from ./map.map mapfile if it exists, if mapfile doesnt exists it will create empty object.
You can use `xml` method to see (export content of the mapfile to xml).
Example of empty MapObj output as xml:

```
<?xml version="1.0" encoding="UTF-8"?>

```
## Public Methods

- MapObj_name xml
- MapObj_name parse
- MapObj_name save
- MapObj_name strip_comments
- MapObj_name list_layers
- MapObj_name print_stack
- MapObj_name parse_line
