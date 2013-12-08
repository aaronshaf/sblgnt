require 'nokogiri'

abbreviations = {
  "Ge" => "Gen",
  "Ex" => "Exod",
  "Le" => "Lev",
  "Nu" => "Num",
  "Dt" => "Deut",
  "Jos" => "Josh",
  "Jud" => "Jude",
  "Ru" => "Ruth",
  "1Sa" => "1Sam",
  "2Sa" => "2Sam",
  "1Ki" => "1Kgs",
  "2Ki" => "2Kgs",
  "1Ch" => "1Chr",
  "2Ch" => "2Chr",
  "Ezr" => "Ezra",
  "Ne" => "Neh",
  "Es" => "Esth",
  "Job" => "Job",
  "Jdg" => "Judg",
  "Ps" => "Ps",
  "Pr" => "Prov",
  "Ec" => "Eccl",
  "So" => "Song",
  "Is" => "Isa",
  "Je" => "Jer",
  "La" => "Lam",
  "Eze" => "Ezek",
  "Da" => "Dan",
  "Ho" => "Hos",
  "Joe" => "Joel",
  "Am" => "Amos",
  "Ob" => "Obad",
  "Jon" => "Jonah",
  "Mic" => "Mic",
  "Na" => "Nah",
  "Hab" => "Hab",
  "Zep" => "Zeph",
  "Hag" => "Hag",
  "Zec" => "Zech",
  "Mal" => "Mal",
  "Mt" => "Matt",
  "Mk" => "Mark",
  "Lk" => "Luke",
  "Lu" => "Luke",
  "Jn" => "John",
  "Ac" => "Acts",
  "Ro" => "Rom",
  "1Co" => "1Cor",
  "2Co" => "2Cor",
  "Gal" => "Gal",
  "Ga" => "Gal",
  "Eph" => "Eph",
  "Php" => "Phil",
  "Col" => "Col",
  "1Th" => "1Thess",
  "2Th" => "2Thess",
  "1Ti" => "1Tim",
  "2Ti" => "2Tim",
  "1Tim" => "1Tim",
  "2Tim" => "2Tim",
  "Titus" => "Tit",
  "Tit" => "Tit",
  "Phm" => "Phlm",
  "Heb" => "Heb",
  "Jam" => "Jas",
  "Jas" => "Jas",
  "1Pe" => "1Pet",
  "2Pe" => "2Pet",
  "1Jn" => "1John",
  "2Jn" => "2John",
  "3Jn" => "3John",
  "Re" => "Rev"
}

xml = File.open('../xml/new-testament.xml')

doc = Nokogiri::XML(xml)

doc.xpath("//book").each do |book|
  abbreviation = book.attribute('id').to_s.gsub(' ','')
  osisAbbreviation = abbreviations[abbreviation]

  puts osisAbbreviation
  
  if(!File.directory?("../xml/" + osisAbbreviation))
    Dir::mkdir("../xml/" + osisAbbreviation)
  end

  chapter = nil
  paragraph = nil

  chapterNumber = "1"
  paddedChapterNumber = chapterNumber.rjust(3, "0")

  book.children.each do |p|
    if p.name != 'p'
      next
    end

    if chapter != nil
      paragraph = Nokogiri::XML::Node.new("p",chapter)
    end

    p.children.each do |child|
      if child.name == 'verse-number'
        if child.text.end_with?(':1')
          if chapter != nil
            if paragraph.xpath("w").length > 0
              chapter.root.add_child(paragraph)
            end
            
            File.open("../xml/#{osisAbbreviation}/#{paddedChapterNumber}.xml","w") do |fileToWrite|
              xml = chapter.to_xml
              doc = Nokogiri::XML(xml,&:noblanks)
              fileToWrite.write doc.to_xml(:encoding => 'UTF-8')
            end
          end

          chapterNumber = child.text.gsub(':1','')
          paddedChapterNumber = chapterNumber.rjust(3, "0")

          chapter = Nokogiri::XML::Document.new
          chapter.root = Nokogiri::XML::Node.new("chapter",chapter)
          paragraph = Nokogiri::XML::Node.new("p",chapter)
        end
      end

      if paragraph != nil
        paragraph.add_child(child)
      end
    end

    if chapter != nil and paragraph.children.length > 0
      chapter.root.add_child(paragraph)
    end
  end

  File.open("../xml/#{osisAbbreviation}/#{paddedChapterNumber}.xml","w") do |fileToWrite|
    xml = chapter.to_xml
    doc = Nokogiri::XML(xml,&:noblanks)
    fileToWrite.write doc.to_xml(:encoding => 'UTF-8')
  end
end
