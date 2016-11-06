require 'nokogiri'

hw_styles = File.open("hanswehr_styles.xml") { |f| Nokogiri::XML(f)}
hw_source = File.open("hanswehr_content_only.xml") { |f| Nokogiri::XML(f) }

margins = Hash.new {|h,k| h[k]=[]}

hw_styles.xpath("//style:paragraph-properties[@fo:margin-left]").each do |m|
    margins[m["fo:margin-left"]] << m.parent["style:name"]
end

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close