require 'zip'
require 'tmpdir'
require 'json'

if $ARGV[0].nil?
    puts "Usage: " + $0 + " <Slack export file.zip>"
    exit
end

result = Hash.new

begin
    Dir.mktmpdir do |tmpdir|
        Zip::File.open($ARGV[0]) do |zip|
            zip.each do |entry|
                p entry.name
                zip.extract(entry, tmpdir + entry.name) { true }

                # ディレクトリは無視する
                if entry.name.slice(-1) == "/"
                    next
                end

                file = File.open(tmpdir + entry.name, "r")
                contents = JSON.parse(file.read)
                
                contents.each do |item|
                    result[entry.name] = [item["text"], item["ts"]]
                end
            end
        end
    end
rescue
    puts "Cannot open " + $ARGV[0]
end

result.sort.each do |item|
    p item
end
