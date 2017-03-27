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
current_root_id = -1;
autonum = 1
current_root = nil

def check_is_root(tag)
	styleMatch = $root_word_styles.include? tag.attributes["style-name"].value
	# matches a lot of root words based on fitting the expression "فعل fa'ala a" with some extra checks
	# has to be directly at the beginning of the definition
	# rootBeginningRegex = /^\d?[\u0620-\u0660]{3} *[a-z']+ *[aiu] / 
    regexMatch = false; # not yet implemented
    romanNumeralsMatch = /(II|III|IV|V |VI|VII|VIII|IX|X)/ =~ tag.text
    
	return styleMatch || regexMatch || romanNumeralsMatch
end

def check_is_thulaathi(word)
    romanNumeralsMatch = /(II|III|IV|V |VI|VII|VIII|IX|X)/ =~ word[:text]
    # other checks?

	return romanNumeralsMatch
end

# Open a database
File.delete("hanswehr.db")
puts "Deleted existings hanswehr.db"

db = SQLite3::Database.new "hanswehr.db"
puts "Opened (created) hanswehr.db"

sql_file = File.open("create.sql", "rb")
create_db = sql_file.read
sql_file.close

# db.execute create_db #doesnt work
`cat create.sql | sqlite3 hanswehr.db`
puts "Created tables in hanswehr.db"


insert = db.prepare <<-SQL
    INSERT INTO WordView (rowid, RootWordId, ArabicWord, IsRoot, Definition)
    VALUES (?,?,?,?,?)
SQL

puts "Beginning parse"
hw_source.xpath("//office:text/text:p")
	.each{ |tag| 
            word = { 
            	id: autonum,
                word: word_regex.match(tag.text).to_s, 
                text: tag.text, 
                is_root: check_is_root(tag),
            }

            #check if this word is really derived from the root.
            root_letters = current_root[:word] rescue ""
            letters = word[:word]
            derivedCheckRegex = Regexp.new("^[سألتمونيهاةءؤئىآ#{root_letters}]+$")
            
            word[:is_thulaathi] = check_is_thulaathi(word)
            if word[:is_thulaathi]
                current_root = word
                current_root_id = autonum 
                word[:is_root] = true
                word[:root] = -1;
            end

            if !word[:is_thulaathi] and derivedCheckRegex =~ word[:word] then
                # puts "YES: #{letters} derived from #{root_letters}" 
                word[:root] = current_root_id
            else
                # puts "NO: #{letters} NOT derived from #{root_letters}"      
                word[:root] = -1                         
            end


            autonum += 1 
            res = insert.execute word[:id],word[:root],word[:word],word[:is_root] ? 1 : 0,word[:text]
        } 





# File.write 'results.json', root_words[0...10000].to_json



# Pry::ColorPrinter.pp(styles.sort_by{|k,v| k}.to_h)

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close