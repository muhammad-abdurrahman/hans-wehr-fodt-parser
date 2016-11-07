require 'nokogiri'
require 'pry'

hw_source = File.open("hanswehr.xml") { |f| Nokogiri::XML(f) }

styles = Hash.new {|h,k| h[k]=[]}

hw_source.xpath("//style:paragraph-properties[@fo:margin-left]").each do |s|
    styles["#{s["fo:margin-left"].tr('in','').to_f + s["fo:text-indent"].tr('in','').to_f}"] << s.parent["style:name"]
end

Pry::ColorPrinter.pp(styles.sort_by{|k,v| k}.to_h)

# f_out = File.new("out.txt", "w+")

# f_out.write hw_source.xpath("//text:p[@text:style-name='P15']").first
# f_out.close