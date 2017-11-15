require 'ostruct'
require 'nokogiri'
require 'cwgk_loader/constants'
require 'cwgk_loader/utils'
require 'json'

module CwgkLoader
  class CwgkSubmitter
    attr_writer :file
    attr_accessor :document_ids, :collection_ids
    def initialize()
      db_client = Mysql2::Client.new(host: ENV['DB_HOST'], username: ENV['DB_USERNAME'], password: ENV['DB_PASSWORD'], database: ENV['DB_NAME'], port: ENV['DB_PORT'] )
      results = db_client.query("SELECT t.record_id, t.text FROM omeka_element_texts t, omeka_elements e WHERE e.name='Identifier' and e.id=t.element_id")
      @document_ids = results.map { |r|
        [ r['text'].to_sym, r['record_id'].to_s ]
      }.to_h
      results = db_client.query("SELECT collection_id, name FROM omeka_collection_trees")
      @collection_ids = results.map { |r|
        [ r['name'].to_sym, r['collection_id'] ]
      }.to_h
      results = db_client.query("SELECT * FROM omeka_elements")
      @elements_map = results.map { |r|
        [ r['name'].to_sym, { id: r['id'], element_set_id: r['element_set_id'] } ]
      }.to_h
      @elements_map[:Title] = {id: 50, element_set_id: 1}
      @elements_map[:Identifier] = {id: 43, element_set_id: 1}
      @item_types = Utils.get_item_types ENV['API_ROOT']
    end

    def submit_entity(file)
      entity = OpenStruct.new
      doc = Nokogiri::XML(File.open(file))
      entity.public = true
      entity.featured = false

      entity.identifier = doc.xpath('//tei:TEI/@xml:id', tei: TEI_NS).first.to_s
      # due to a bug, use file name
      entity.identifier = File.basename(file, '.*')

      item_id = @document_ids[entity.identifier.to_sym]

      entity.item_type = { id: item_type(entity.identifier)}
      entity.element_texts = Utils.entity_element_map(entity.identifier).collect { |name, xpath|
        build_element name, xpath, doc
      }.flatten

      if item_id.nil?
        response = RestClient.post "#{ENV['API_ROOT']}/items?key=#{ENV['API_KEY']}", entity.to_h.to_json, { content_type: :json }
      else
        response = RestClient.put "#{ENV['API_ROOT']}/items/#{item_id}?key=#{ENV['API_KEY']}", entity.to_h.to_json, { content_type: :json }
      end
      if response.code == 200 or response.code == 201
        item_id = JSON.parse(response.body)['id']
        Utils.upload_file file, item_id, ENV['API_ROOT'], ENV['API_KEY']
      else
        Utils.logger.warn "PUT/POST #{entity.identifier} failed: " + response.body
      end
    end

    def submit_document(file)
      document = OpenStruct.new
      doc = Nokogiri::XML(File.open(file))
      collection_nodes = doc.xpath('//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:collection/text()', tei: TEI_NS)
      if collection_nodes.size == 0
        Utils.logger.warn "Couldn't find collection name in TEI. #{file} \n Please check xpath //teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/collection"
        return
      else
        collection_name = collection_nodes.first.to_s.gsub(/\s+/, ' ').strip.to_sym
        if @collection_ids.has_key? collection_name
          document.collection = { id: @collection_ids[collection_name] }
        else
          # TODO: create a new collection
          Utils.logger.warn "Couldn't find collection in Omeka: #{collection_name}"
          return
        end
      end
      document.public = true
      document.featured = false
      document.identifier = doc.xpath('//tei:TEI/@xml:id', tei: TEI_NS).first.to_s

      item_id = @document_ids[document.identifier.to_sym]
      document.item_type = { id: 18 }
      document.element_texts = DOCUMENT_ELEMENT_MAP.collect { |name, xpath|
        build_element name, xpath, doc
      }.flatten

      if item_id.nil?
        response = RestClient.post "#{ENV['API_ROOT']}/items?key=#{ENV['API_KEY']}", document.to_h.to_json, { content_type: :json }
      else
        response = RestClient.put "#{ENV['API_ROOT']}/items/#{item_id}?key=#{ENV['API_KEY']}", document.to_h.to_json, { content_type: :json }
      end

      if response.code == 200 or response.code == 201
        item_id = JSON.parse(response.body)['id']
        Utils.upload_file file, item_id, ENV['API_ROOT'], ENV['API_KEY']
      else
        Utils.logger.warn "PUT/POST #{document.identifier} failed: " + response.body
      end
    end

    def build_element(element_name, xpath, tei_doc)
      nodes = tei_doc.xpath(xpath, tei: TEI_NS)
      elements = []
      if nodes.size == 0
        Utils.logger.warn "No nodes found: #{element_name}, #{xpath}"
      else
        values = nodes.map { |node|
          if xpath == '//tei:body' or xpath == '//tei:back/tei:ab/tei:bibl'
            node.content.to_s.gsub(/\n+/, "\n").strip
          elsif element_name == :Latitude
            node.content.to_s.split[0].strip
          elsif element_name == :Longitude
            node.content.to_s.split[1].strip
          else
            node.to_s.gsub(/\s+/, ' ').strip
          end
        }.uniq
        elements = values.map { |value|
          data = OpenStruct.new
          data.html = false
          data.element_set = {id: @elements_map[element_name][:element_set_id]}
          data.element = {id: @elements_map[element_name][:id]}
          data.text = value
          data.to_h
        }
      end
      return elements
    end
    private :build_element

    def item_type(id)
      if id.start_with?('N')
        return @item_types['CWGK Person']
      elsif id.start_with?('O')
        return @item_types['CWGK Organization']
      elsif id.start_with?('P')
        return @item_types['CWGK Place']
      elsif id.start_with?('G')
        return @item_types['CWGK Geographical Feature']
      else
        return nil
      end
    end
    private :item_type
  end
end