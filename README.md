# json_nested_array_to_csv

A command-line script to convert a particular style of JSON object to a CSV file. (Pretty naive, built for a specific use).

# How to use
1. Place script in same folder as files you wish to convert (do not need JSON sample).
2. open Terminal of choice in that folder.
3. run `ruby json_with_array_to_csv_generator.rb --json sample --csv my_csv_file` where `sample` is the name of the JSON file you wish to convert and `my_csv_file` is the name you wish to use for the CSVs generated. Multiple CSVs will have an incrementing id at the end.
4. You may also use `-j` and `-c` in place of `--json` and `--csv`. Access help screen anytime using `-h` or `--help`.

# Example

This takes a JSON object as follows, let's say in a file called `baking.json`.

### `baking.json`
```
{ 
  "syrup": [
    { "type": "maple", "made_in": "canada" }, 
    { "type": "simple" }
  ],
  "pancake" : [
    { "size": 20, "type": "sourdough" },
    { "size": 10, "type": "wheat", "contains_allergens": true }
  ]
}
```
And converts each top level key's array into a unique csv file. So we run `ruby json_with_array_to_csv_generator.rb --json baking --csv baking_collection` 

Which results in the following CSV files.

### `baking_collection.csv`
```
made_in, type
canada, maple
'', simple
```
### `baking_collection2.csv`
```
contains_allergens, size, type
'', 20, sourdough
true, 10, wheat
