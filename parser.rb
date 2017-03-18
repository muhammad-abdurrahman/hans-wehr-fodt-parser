require 'nokogiri'
require 'json'
require "sqlite3"
# require 'pry'

# # check unicode values for arabic characters (between 1571 and 1618)
# ara_chars = "ابتثجحخدذرزسشصضطظعغفقكلمنهويأإىؤءئًٌٍَُِّْ"
# ara_chars.chars.each { |char| puts char + ": " + char.ord.to_s } 



hw_source = File.open("hanswehr.xml") { |f| Nokogiri::XML(f) }

styles = Hash.new {|h,k| h[k]=[]}

hw_source.xpath("//style:paragraph-properties[@fo:margin-left]").each do |s|
    styles["#{s["fo:margin-left"].delete('in').to_f + s["fo:text-indent"].delete('in').to_f}"] << s.parent["style:name"]
end


$root_word_styles = styles["0.0"]

word_regex = /(?<=[ (\d])?[\u0620-\u0660]+/
current_root = nil;
autonum = 1

def check_is_root(tag)
	styleMatch = $root_word_styles.include? tag.attributes["style-name"].value
	# matches a lot of root words based on fitting the expression "فعل fa'ala a" with some extra checks
	# has to be directly at the beginning of the definition
	# rootBeginningRegex = /^\d?[\u0620-\u0660]{3} *[a-z']+ *[aiu] / 
    regexMatch = false; # not yet implemented
    romanNumeralsMatch = false # not yet implemented
    
	return styleMatch || regexMatch || romanNumeralsMatch
end

# Open a database
File.delete("hanswehr.db")
puts "Deleted existings hanswehr.db"

db = SQLite3::Database.new "hanswehr.db"
puts "Opened (created) hanswehr.db"

sql_file = File.open("create.sql", "rb")
create_db = sql_file.read
sql_file.close

puts create_db

# db.execute create_db #doesnt work
`cat create.sql | sqlite3 hanswehr.db`
puts "Created tables in hanswehr.db"


current_root = autonum

insert = db.prepare <<-SQL
    INSERT INTO WordView (rowid, RootWordId, ArabicWord, IsRoot, Definition)
    VALUES (?,?,?,?,?)
SQL

puts "Prepared insert query, about to parse"
hw_source.xpath("//office:text/text:p")
	.each{ |tag| 
            word = { 
            	id: autonum,
                word: word_regex.match(tag.text).to_s, 
                text: tag.text, 
                is_root: check_is_root(tag),
                root: current_root
            }
            insert.execute word[:id],word[:root],word[:word],word[:is_root] ? 1 : 0,word[:text]
            current_root = autonum if word[:is_root]
            autonum += 1 
        } 





# File.write 'results.json', root_words[0...10000].to_json



# Pry::ColorPrinter.pp(styles.sort_by{|k,v| k}.to_h)

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close