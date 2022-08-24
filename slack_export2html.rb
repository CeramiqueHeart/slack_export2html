require 'zip'
require 'tmpdir'
require 'json'

if $ARGV[0].nil?
    puts "Usage: " + $0 + " <Slack export file.zip>"
    exit
end

entry = Hash.new

#begin
    Dir.mktmpdir do |tmpdir|
        Zip::File.open($ARGV[0]) do |zip|
            zip.each do |zip_file|
                zip.extract(zip_file, tmpdir + zip_file.name) { true }

                # ディレクトリは無視する
                next if zip_file.name.slice(-1) == "/"

                # ディレクトリに含まれないファイルは無視する
                next if not zip_file.name.include?("/")

                if entry[zip_file.name].nil?
                    entry[zip_file.name] = Array.new
                end

                JSON.parse(zip_file.get_input_stream.read).each do |item|
                    entry[zip_file.name].push(item)
                end
            end
        end
    end
#rescue
#    puts "Cannot open " + $ARGV[0]
#end

result = Hash.new
entry.sort.each do |item|
    channel = item[0].split('/')[0]
    if result[channel].nil?
        result[channel] = Array.new
    end
    result[channel].push(item[1])
end

result.each_key do |result_key|
    file = File.open(result_key + ".html", "w")

    result[result_key].each do |day_item|
        day_item.each do |item|
            date = Time.at(item["ts"].to_i).strftime("%Y-%m-%d")

            # textが空の場合はfilesとして処理する
            if item["text"].nil?
                contents = item["files"][0]["url_private_download"]
            else
                contents = item["text"]
            end

            file.write date + "\n"
            file.write contents + "\n"
        end
 #       day_item.each do |item|
 #           text = item[0]
 #           ts   = item[1]
 #           date = Time.at(ts.to_i).strftime("%Y-%m-%d")
#
 #           file.write date + "\n"
 #           file.write text + "\n"
 #       end
    end
end
