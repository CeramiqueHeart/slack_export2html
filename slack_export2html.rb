require 'zip'
require 'tmpdir'

if $ARGV[0].nil?
    puts "Usage: " + $0 + " <Slack export file.zip>"
    exit
end

begin
    Dir.mktmpdir do |tmpdir|
        Zip::File.open($ARGV[0]) do |zip|
            zip.each do |entry|
                p entry.name
                zip.extract(entry, tmpdir + entry.name) { true }
            end
        end
    end
rescue
    puts "Cannot open " + $ARGV[0]
end

