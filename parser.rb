require 'nokogiri'
require 'json'

hw_styles = File.open("hanswehr_styles.xml") { |f| Nokogiri::XML(f)}
hw_source = File.open("hanswehr_content_only.xml") { |f| Nokogiri::XML(f) }

styles = Hash.new {|h,k| h[k]=[]}

hw_styles.xpath("//style:paragraph-properties[@fo:margin-left]").each do |s|
    styles["ml="+s["fo:margin-left"]+"_ti="+s["fo:text-indent"]] << s.parent["style:name"]
end

puts JSON.pretty_generate(styles).gsub(":", " =>")

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close