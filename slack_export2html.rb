require 'zip'
require 'tmpdir'
require 'json'

if $ARGV[0].nil?
    puts "Usage: " + $0 + " <Slack export file.zip>"
    exit
end

entry = Hash.new

begin
    Dir.mktmpdir do |tmpdir|
        Zip::File.open($ARGV[0]) do |zip|
            zip.each do |zip_entry|
                zip.extract(zip_entry, tmpdir + zip_entry.name) { true }

                # ディレクトリは無視する
                next if zip_entry.name.slice(-1) == "/"

                # ディレクトリに含まれないファイルは無視する
                next if not zip_entry.name.include?("/")

                JSON.parse(zip_entry.get_input_stream.read).each do |item|
                    entry[zip_entry.name] = [item["text"], item["ts"]]
                end
            end
        end
    end
rescue
    puts "Cannot open " + $ARGV[0]
end

result = Hash.new([])
entry.sort.each do |item|
    channel = item[0].split('/')[0]
    result[channel] = result[channel].push(item[1])
end

result.each do |key, value|
    p key
    p value
end