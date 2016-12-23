require 'nokogiri'
# require 'pry'

# # check unicode values for arabic characters (between 1571 and 1618)
# ara_chars = "ابتثجحخدذرزسشصضطظعغفقكلمنهويأإىؤءئًٌٍَُِّْ"
# ara_chars.chars.each { |char| puts char + ": " + char.ord.to_s } 

hw_source = File.open("hanswehr.xml") { |f| Nokogiri::XML(f) }

styles = Hash.new {|h,k| h[k]=[]}

hw_source.xpath("//style:paragraph-properties[@fo:margin-left]").each do |s|
    styles["#{s["fo:margin-left"].delete('in').to_f + s["fo:text-indent"].delete('in').to_f}"] << s.parent["style:name"]
end

p "alif hamza: " "أ".ord

root_word_styles = styles["0.0"]

regex = /(?<= |^)[\u0620-\u0660 ]+(?= |$)/

root_words = hw_source.xpath("//office:text/text:p")
	.map{ |tag| 
            { 
                word: regex.match(tag.text).to_s, 
                text: tag.text, 
                style: tag.attributes["style-name"].value, 
                is_root: root_word_styles.include?(tag.attributes["style-name"].value)
            }
        } 

root_words.each { |rw| puts rw };


# Pry::ColorPrinter.pp(styles.sort_by{|k,v| k}.to_h)

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close