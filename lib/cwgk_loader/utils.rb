require 'logger'
require 'cwgk_loader/constants'
require 'git'
require 'rest-client'

module CwgkLoader
  module Utils
    class << self
      attr_accessor :logger
    end

    self.logger = Logger.new(STDOUT)

    def git_pull(git_dir)
      git = Git.open(git_dir, log: CwgkLoader::Utils.logger)
      git.config('user.name', ENV['GIT_USER'])
      git.config('user.email', ENV['GIT_EMAIL'])
      git.pull
    end
    module_function :git_pull

    def upload_file(filename, item_id, api_root, api_key)
      files = RestClient.get "#{api_root}/files?item=#{item_id}"
      files = JSON.parse(files.body)
      file_id = nil
      files.each do |file|
        if file['original_filename'] == File.basename(filename)
          file_id = file['id']
        end
      end
      if !file_id.nil?
        # delete the old file
        response = RestClient.delete "#{api_root}/files/#{file_id}?key=#{api_key}"
        logger.warn "Deleting file failed: #{file_id}: [#{response.code}] #{response.body}" unless response.code == 204
        # post a file
      end
      payload = { multipart: true, file: File.new(filename, 'rb'), data: { item: { id: item_id } }.to_json }
      response = RestClient.post "#{api_root}/files?key=#{api_key}", payload
      if response.code == 201
        logger.info "POSTED file: #{filename}"
      else
        logger.warn "POST file failed: [#{response.code}] #{filename}, #{response.code}"
      end
    end
    module_function :upload_file

    def collection_ids
    end

    def get_elements(api_root)
      result = RestClient.get "#{api_root}/elements"
      elements = JSON.parse(result.body)
      elements.map { |element| [element[:name], { id: element[:id], element_set_id: element[:element_set][:id] }] }.to_h
    end
    module_function :get_elements

    def get_item_types(api_root)
      result = RestClient.get "#{api_root}/item_types"
      JSON.parse(result.body).map { | item_type | [item_type['name'], item_type['id']] }.to_h
    end
    module_function :get_item_types

    def entity_element_map(id)
      if id.start_with?('N')
        return PERSON_ELEMENT_MAP
      elsif id.start_with?('O')
        return ORGANIZATION_ELEMENT_MAP
      elsif id.start_with?('P')
        return PLACE_ELEMENT_MAP
      elsif id.start_with?('G')
        return GEOFEATURE_ELEMENT_MAP
      else
        return nil
      end
    end
    module_function :entity_element_map

  end
end