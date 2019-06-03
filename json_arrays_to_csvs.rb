require 'csv'
require 'json'
require 'pry'

json_filename = nil
csv_filename = nil
command_line_input = ARGV || [];
notify = Proc.new { |text| puts text }
notify_and_exit = Proc.new { |text| notify.call(text); exit; }

# make terminal completion/errors more apparent by coloring them & appending a special sign
green_text = Proc.new { |text| "\e[32m--> #{text}\e[0m" }
red_text = Proc.new { |text| "\e[31m!!! #{text}\e[0m" }

# if its all empty, terminate
command_line_input.empty? && notify_and_exit.call('[-j --json], [-c --csv] are valid flags. Use -h or --help for help with how to use them.')

# handle arguments
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
  data = JSON.parse(json_info)
rescue
  notify_and_exit.call(red_text.call('JSON was invalid. Check format and try again.'))
end

# cycle through each top level key to parse its array into a file
data.each do |k, array_entry|
  headers_collection = []
  sorted_collection = {}

  # get all unique headers across entries
  array_entry.each do |entry|
    entry.keys.each do |key|
      headers_collection.push(key) unless headers_collection.include?(key)
    end
  end

  # create missing keys per entry in order to make all entries keys identical,
  # default these new keys to a value of ''
  array_entry.each do |entry|
    headers_collection.each do |header|
      entry[header] ||= ''
    end
  end

  # make sure hashes are sorted so that their values line up for later
  # formulate new entry objects because mutating hashes is weird and unreliable
  sorted_collection = array_entry.map.with_index do |entry, i|
    array_entry[i].sort_by { |ky, _| ky }.to_h
  end

  csvname = "#{csv_filename}-#{k}.csv"

  # ensure that the new files won't overwrite any existing ones
  begin
    all_csvs = Dir["**/*.csv"]
    all_csvs.include?(csvname) && raise
  rescue
    notify_and_exit.call(red_text.call('Using this csv name will cause files to be overwritten. Please use a unique name and try again.'))
  end

  # create the CSV
  CSV.open(csvname, "wb") do |csv|
    # we only need 1 example of the headers since all entries now have them.
    csv << sorted_collection[0].keys
    # now insert the rows
    sorted_collection.each do |entry|
      csv << entry.values
    end
  end

  notify.call(green_text.call("#{Dir.pwd}/#{csv_filename}-#{k}.csv has been generated."))
end
notify_and_exit.call(green_text.call('done'))
