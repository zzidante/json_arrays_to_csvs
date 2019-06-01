require 'csv'
require 'json'
require 'pry'

# fill in these with your own info
name_of_json_file_which_is_sibling_of_this_file = nil # example: "sample_name_no_extension"
name_of_csv_file_you_want = nil # example: "my_super_special_set_of_data"

# or just get input through Command Line
command_line_input = ARGV || [];

# if its all empty, terminate
if command_line_input.empty? && (name_of_json_file_which_is_sibling_of_this_file.nil? || name_of_csv_file_you_want.nil?)
  puts 'Use -h, or --help for help.'
  exit
end

# parse the command line input array
arguments_provided = []
command_line_input.each_with_index do | args, index |
  case args 
  when '--json', '-j'
    then 
    name_of_json_file_which_is_sibling_of_this_file ||= command_line_input[index + 1]
    arguments_provided.push(true)
  when '--csv', '-c'
    then 
    name_of_csv_file_you_want ||= command_line_input[index + 1]
    arguments_provided.push(true)
  when '--help', '-h'
    puts <<~HEREDOC.gsub(/\n/, " ");
      To use this, copy this script's file into the same folder as the JSON you wish to
      parse into a CSV file. Use `-j` or `--json` followed by a space & the name of
      the file you use to convert.  Then use `-c` or `--csv` followed by a space and 
      then a name you would like the soon-to-be generated csv to be called. No extensions
      are needed. No spaces in the name are best since this is just a simple script.
      Example call ($: represents terminal): 
      `$: ruby #{$0} -j sample -c converted_sample` 
    HEREDOC
    exit
  end
end

if arguments_provided.length != 2
  puts '[-j --json], [-c --csv] are valid flags. Use -h or --help for help with how to use them.'
  exit
end

# read JSON 
json_info = File.open("#{name_of_json_file_which_is_sibling_of_this_file}.json").read

# transform to Ruby object for parsing 
begin
  json_info_now_ruby_object = JSON.parse(json_info)
rescue 
  puts 'JSON was invalid. Check format and try again.'
  exit
end

json_info_now_ruby_object.each do |k, array_entry|
  headers_collection = []
  sorted_collection = {}

  array_entry.each do |entry|
    entry.keys.each do |key|
      headers_collection.push(key) unless headers_collection.include?(key)
    end
  end
  array_entry.each do |entry|
    headers_collection.each do |header|
      # if the object doesn't have the header, default a value to ''
      entry[header] ||= ''
    end 
  end

  # make sure hashes are sorted so that their values line up for later 
  # formulate new entry objects because mutating hashes is weird and oddly unreliable
  sorted_collection[k] = []

  array_entry.each_with_index do |entry, i|
    sorted_entry = array_entry[i].sort_by { |ky, _| ky }.to_h
  
    sorted_collection[k].push(sorted_entry)
  end

  # creates new CSVs for each top level key JIC they exist.
  sorted_collection.each do |key, collection|
    sorted_collection[key].each_with_index do |entry, i|
      
      csv = CSV.open("#{name_of_csv_file_you_want}-#{key}.csv", "wb") do |csv|
        # we only need 1 example of the headers since all entries now have them.
        csv << sorted_collection[key][0].keys
        collection.each do |entry|
          csv << entry.values
        end
      end
    end
  end
end

puts Dir.pwd + '/' + name_of_csv_file_you_want + '.csv' + ' has been generated.'
