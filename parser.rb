require 'nokogiri'

hans_wehr_source = File.open("hanswehr.xml") { |f| Nokogiri::XML(f) }
