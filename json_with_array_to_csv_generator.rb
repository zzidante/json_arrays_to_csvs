require 'csv'
require 'json'
require 'pry'

json_filename = nil
csv_filename = nil
command_line_input = ARGV || [];
notify_and_exit = Proc.new { |text| puts text; exit; }

# if its all empty, terminate
command_line_input.empty? && notify_and_exit.call('[-j --json], [-c --csv] are valid flags. Use -h or --help for help with how to use them.')

command_line_input.each_with_index do |args, index|
  case args
  when '--json', '-j'
    then
    json_filename = command_line_input[index + 1]

  when '--csv', '-c'
    then
    csv_filename = command_line_input[index + 1]

  when '--help', '-h'
    # remove newlines so CLI output wraps correctly
    notify_and_exit.call(<<~HEREDOC.gsub(/\n/, " "))
      To use this, copy this script's file into the same folder as the JSON you wish to
      parse into a CSV file. Use `-j` or `--json` followed by a space & the name of
      the file you use to convert. Then use `-c` or `--csv` followed by a space and
      then a name you would like the soon-to-be generated csv to be called. No extensions
      are needed. No spaces in the name are best since this is just a simple script.
      Name of top level key will append to the end of the csv filename in case of
      multiple files.
      Example call ($: represents terminal):
      `$: ruby #{$0} -j sample -c converted_sample`
    HEREDOC
  end
end

unless json_filename && csv_filename
  notify_and_exit.call('[-j --json], [-c --csv] are valid flags. Use -h or --help for help with how to use them.')
end

# read JSON
json_info = File.open("#{json_filename}.json").read

# transform to Ruby object for parsing
begin
  json_info_now_ruby_object = JSON.parse(json_info)
rescue
  notify_and_exit.call('JSON was invalid. Check format and try again.')
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

  sorted_collection[k] = array_entry.map.with_index do |entry, i|
    array_entry[i].sort_by { |ky, _| ky }.to_h
  end

  # creates new CSVs for each top level key JIC they exist.
  sorted_collection.each do |key, collection|
    sorted_collection[key].each_with_index do |entry, i|
      csv = CSV.open("#{csv_filename}-#{key}.csv", "wb") do |csv|
        # we only need 1 example of the headers since all entries now have them.
        csv << sorted_collection[key][0].keys
        collection.each do |entry|
          csv << entry.values
        end
      end
    end
  end
end

notify_and_exit.call(Dir.pwd + '/' + csv_filename + '.csv' + ' has been generated.')
