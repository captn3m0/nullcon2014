require 'rubygems'
require 'json'
require 'nokogiri'
require 'rkelly'
require 'mysql2'
require 'timeout'

#Mysql Connection
$con = Mysql2::Client.new(:host => "localhost", :username => "root", :password=>"nemoabhay",:database=>"helios")
$http_requests={}
manifestVersion2Count=0
Encoding.default_external = Encoding::UTF_8 #required to make sure that all json is parsed as utf8
$parser = RKelly::Parser.new

# Scans a js blob for any vulnerabilities
def ScanScript(contents,item)
  ast=nil
  begin
    Timeout::timeout(20) do
      #Do something that takes long time
      ast=$parser.parse (contents)
    end
  rescue Timeout::Error
    puts "RKelly timed out"
    return
  end
  unless ast.nil?
    ast.each do |node|
      if node.class==RKelly::Nodes::FunctionCallNode
        extension_call=node.to_ecma
        if(extension_call[0..5]=='chrome')
          extension_call=extension_call.split("(").first.split(".")[1]
          puts extension_call
          unless extension_call.nil?
            extension_call=$con.escape(extension_call)
            $con.query("INSERT IGNORE INTO `usage2` (`extension`,`api`) VALUES ('#{item}','#{extension_call}')")
          end
        end
      end
    end
  else
    puts "AST = nil"
  end
end

#Scans an html file for any script tags
def ScanHTMLFile(path, item)
  #Open the html file, parse it with nokogiri, and get a list of all script tags
  dir=File.dirname(path)
  f=File.open(path)
  doc=Nokogiri::HTML(f)
  scriptTags=doc.css("script")
  scriptTags.each do |script|
    #If the script tag is inline
    if(script.inner_html.chomp.length>1)
      source=script.inner_html
      ScanScript(source, item)
    else
      unless(script["src"].nil?)
        if(script["src"][0..4].downcase=='http:')
          #Get the request address and log it.
          puts script["src"]
          url=$con.escape(script['src'])
          #puts ("INSERT INTO http_requests (`extension`,`url`) VALUES ('#{item}','#{url}')")
          $con.query("INSERT INTO http_requests2 (`extension`,`url`) VALUES ('#{item}','#{url}')")
        else
          #ScanLocalScript("#{dir}/#{script['src']}", item) 
        end
      end
    end
  end
  f.close
end

def ScanLocalScript(path,item)
  #Don't scan jquery at least
  return if (File.basename(path)[0..5]=="jquery" or File.basename(path)=='d3.js')
  #puts File.basename path
  contents=File.read(path)
  ScanScript(contents, item)
end

extensionCounter=0

Dir.foreach('./unzipped') do |item|
  print "\n##{extensionCounter} - #{item}"
  print "\n"
  next if item == '.' or item == '..'
  extensionCounter+=1
  #If this is present in the database, skip
  next if extensionCounter<=6844
  results=$con.query("SELECT * from `usage2` where `extension`='#{$con.escape(item)}'")
  next if results.count>=1
  
  json=File.read("./unzipped/#{item}/manifest.json")
  begin
    manifest=JSON.parse(json)

    ##Manifest Version
  	if(manifest.has_key?("manifest_version"))
  	  manifestVersion2Count=manifestVersion2Count+1
    else
      #Older Manifest Stuff
    end
    
    #Default_popup HTML File
    if(manifest.has_key?("browser_action") && manifest["browser_action"].has_key?("default_popup"))
      filePath=manifest["browser_action"]["default_popup"]
      ScanHTMLFile("./unzipped/#{item}/#{filePath}", item)
    end
    
    #Default popup for page_action
    if(manifest.has_key?("page_action") && manifest["page_action"].has_key?("default_popup"))
      filePath=manifest["page_action"]["default_popup"]
      ScanHTMLFile("./unzipped/#{item}/#{filePath}", item)
    end
    
    #Content scripts
    if(manifest.has_key?("content_scripts"))
      manifest["content_scripts"].each do |contentScriptItem|
        if(contentScriptItem.has_key?("js"))
          contentScriptItem["js"].each do |script|
            ScanLocalScript("./unzipped/#{item}/#{script}", item)
          end
        end
      end
    end
    
    #Options page
    if(manifest.has_key?("options_page"))
      ScanHTMLFile("./unzipped/#{item}/#{manifest['options_page']}", item)
    end
    
    #Background html or js files
    if(manifest.has_key?("background"))
      #Older manifests have background as the direct html file, without using the "page" key
      if(manifest["background"].is_a? String)
        ScanHTMLFile("./unzipped/#{item}/#{manifest['background']}", item)
      #Background page
      elsif(manifest["background"].has_key?("page"))
        filePath=manifest["background"]["page"]
        ScanHTMLFile("./unzipped/#{item}/#{filePath}", item)
      #Background js file
      elsif(manifest["background"].has_key?("scripts"))
        manifest["background"]["scripts"].each do |script|
          ScanLocalScript("./unzipped/#{item}/#{script}", item)
        end
      end
    end
    
  #We catch errors here
  rescue RKelly::SyntaxError => e
    puts "Syntax Error in JS"
  rescue RuntimeError => e
    puts
     "Runtime Error"
    next
  #Parser error in rkelly
  rescue ArgumentError => e
    puts "RKelly Parse Error"
  #A file was not found. We just skip over this
  rescue Errno::ENOENT => e
    puts "File not found"
  #We face some json parsing errors
  rescue JSON::ParserError => e
    puts "Manifest Parsing error"
  	next
  end
  #Insert a blank value into usage table, so we can keep track of
  #Even those extensions which do not use any APIs
  #$con.query("INSERT IGNORE INTO `usage2` (`extension`,`api`) VALUES ('#{item}','')")
end

puts "Manifest Version 2 Count: #{manifestVersion2Count}"
puts "HTTP Requests Count: #{$http_requests}"
