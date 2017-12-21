module CwgkLoader
  TEI_NS = 'http://www.tei-c.org/ns/1.0'

  DOCUMENT_ELEMENT_MAP = {
      'Accession Number':     '//tei:TEI/@xml:id',
      'Document Title':       '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type="main"]/text()',
      'Editorial Notes':      '//tei:notesStmt/tei:note[@type="editorial"]/text()',
      'Source Country':       '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:country/text()',
      'Source State':         '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:region/text()',
      'Source City':          '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement/text()',
      'Repository':           '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/text()',
      'Collection':           '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:collection/text()',
      'Item Location':        '//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno/text()',
      'Date of Creation':     '//tei:teiHeader/tei:profileDesc/tei:creation/tei:date/text()',
      'ISO Date of Creation': '//tei:teiHeader/tei:profileDesc/tei:creation/tei:date/@when',
      'Place of Creation':    '//tei:teiHeader/tei:profileDesc/tei:creation/tei:placeName/text()',
      'Dates Mentioned':      '//tei:body//tei:date/@when',
      'Document Genre':       '//tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term[@type="genre"]/text()',
      'Transcription':        '//tei:body',
      'DocTracker Number':    '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type="parallel"]/text()',
      'Identifier':           '/tei:TEI/@xml:id',
      'Title':                '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type="main"]/text()'
  }

  PERSON_ELEMENT_MAP = {
      'Birth Date':        '//tei:particDesc/tei:person/tei:event[@type="birth"]/tei:ab/text()', # Birth date
      'Death Date':        '//tei:particDesc/tei:person/tei:event[@type="death"]/tei:ab/text()', # Death date
      'Name':              '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Name
      'Entity Type':       '//tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term[@type="type"]/text()' ,  # Entity Type
      'Identifier':        '//tei:particDesc/tei:person/@xml:id',  # Dublin Core / Identifier
      'Title':             '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Dublin Core / Title
      'Biographical Text': '//tei:body',  # Biographical text
      'Bibliography':      '//tei:back/tei:ab/tei:bibl' ,  # Bibliography
      'Gender':            '//tei:particDesc/tei:person/tei:trait[@type="gender"]/@subtype' ,  # Gender
      'Race Description':  '//tei:particDesc/tei:person/tei:trait[@type="race"]/@subtype'   # Race
  }

  ORGANIZATION_ELEMENT_MAP = {
      'Name':              '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Name
      'Entity Type':       '//tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term[@type="type"]/text()' ,  # Entity Type
      'Identifier':        '//tei:particDesc/tei:org/@xml:id',  # Dublin Core / Identifier
      'Title':             '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Dublin Core / Title
      'Biographical Text': '//tei:body',  # Biographical text
      'Bibliography':      '//tei:back/tei:ab/tei:bibl' ,  # Bibliography
      'Creation Date':     '//tei:particDesc/tei:org/tei:event[@type="begun"]/tei:ab/text()', # Creation Date
      'Dissolution Date':  '//tei:particDesc/tei:org/tei:event[@type="ended"]/tei:ab/text()'  # Dissolution Date
  }

  PLACE_ELEMENT_MAP = {
      'Name':              '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Name
      'Entity Type':       '//tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term[@type="type"]/text()' ,  # Entity Type
      'Identifier':        '//tei:settingDesc/tei:place/@xml:id',  # Dublin Core / Identifier
      'Title':             '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Dublin Core / Title
      'Biographical Text': '//tei:body',  # Biographical text
      'Bibliography':      '//tei:back/tei:ab/tei:bibl',  # Bibliography
      'Latitude':          '//tei:settingDesc/tei:place/tei:placeName/tei:location/tei:geo', # Latitude
      'Longitude':         '//tei:settingDesc/tei:place/tei:placeName/tei:location/tei:geo'  # Longitude
  }

  GEOFEATURE_ELEMENT_MAP = {
      'Name':              '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Name
      'Entity Type':       '//tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords/tei:term[@type="type"]/text()' ,  # Entity Type
      'Identifier':        '//tei:settingDesc/teiDesc/tei:place/@xml:id',  # Dublin Core / Identifier
      'Title':             '//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level="a"][@type="main"]/text()' ,  # Dublin Core / Title
      'Biographical Text': '//tei:body',  # Biographical text
      'Bibliography':      '//tei:back/tei:ab/tei:bibl'   # Bibliography
  }
end
