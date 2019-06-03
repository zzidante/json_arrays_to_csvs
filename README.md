# json_arrays_to_csvs.rb

A command-line script to convert a particular style of JSON object to a CSV file. (Pretty naive, built for a specific use).
Used/tested with ruby version `2.4.6p35`. Should work with any Ruby `2.x.x` version.

# How to use
1. Place script in same folder as files you wish to convert (do not need JSON sample).
2. open Terminal of choice in that folder.
3. run `ruby json_arrays_to_csvs.rb --json sample --csv sample-csvs` where `sample` is the name of the JSON file you wish to convert and `sample-csvs` is the name you wish to use for the CSV generated.
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
  "fruit": [
    { "type": "apple", "color": "red" }, 
    { "type": "banana", "status": "ripe" }
  ]
}
```
And converts top level keys arrays into unique csv files. So if we run `ruby json_arrays_to_csvs.rb --json baking --csv baking_collection` 

It will result in the following CSV files.

### `baking_collection-syrup.csv`
```
made_in, type
canada, maple
'', simple
```
### `baking_collection-fruit.csv`
```
color, status, type
red, '', apple
'', ripe, banana
```

## Considerations
- This only handles Keys with Arrays as their values, but it can handle multiples of these cases - it will just spit out multiple files made unique by their key in the name.
- It will reorder everything alphabetically so the resulting CSV values are ordered correctly and will add blank spaces to keys which had no values in those rows. This allows us to handle entries in the Array collection which do not properly align.
- There are only a few basic error cases -> Invalid JSON, no arguments given and invalid arguments given.
