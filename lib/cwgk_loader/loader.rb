require 'thor'
require 'logger'
require 'dotenv'
require 'cwgk_loader/utils'
require 'cwgk_loader/cwgk_submitter'
require 'mysql2'

module CwgkLoader
  class Loader < Thor
    include CwgkLoader::Utils
    desc 'upload [ID]', 'upload files. It can also upload a single file, or multiple files separated by ;.'
    method_option :config, aliases: '-c', desc: 'Configuration file', required: true
    def upload(doc_id=nil)
      raise Thor::Error, "Can't find config file: #{options[:config]}" unless File.file? options[:config]
      Dotenv.load options[:config]
      git_pull ENV['GIT_ROOT_DIR']

      submitter = CwgkSubmitter.new
      if doc_id.nil?
        Utils.logger.info "Upload files in #{ENV['GIT_ROOT_DIR']}/biography_xml that is updated less than 1 day ago"
        entities_modified = Dir["#{ENV['GIT_ROOT_DIR']}/biography_xml/*.xml"].select { |f| File.file?(f) and File.mtime(f) > (Time.now - 60*60*24*1) }
        entities_modified.each do |entity_file|
          Utils.logger.info "Uploading #{File.basename(entity_file)}"
          submitter.submit_entity entity_file
        end

        Utils.logger.info "Upload files in #{ENV['GIT_ROOT_DIR']}/document_xml that is updated less than 1 day ago"
        documents_modified = Dir["#{ENV['GIT_ROOT_DIR']}/document_xml/*.xml"].select { |f| File.file?(f) and File.mtime(f) > (Time.now - 60*60*24*1) }
        # read the documents, validate and link entities.
        documents_modified.each do |document_file|
          Utils.logger.info "Uploading #{File.basename(document_file)}"
          submitter.submit_document document_file
        end
      else
        doc_id.split(':').each do |doc_id|
          filename = doc_id.end_with?('.xml')? doc_id : doc_id + '.xml'
          Utils.logger.info "Uploading #{filename}"
          if doc_id.start_with? 'KYR'
            submitter.submit_document "#{ENV['GIT_ROOT_DIR']}/document_xml/#{filename}"
          elsif 'NOPG'.include? doc_id[0]
            submitter.submit_entity "#{ENV['GIT_ROOT_DIR']}/biography_xml/#{filename}"
          else
            Utils.logger.error "Invalid identifier: #{doc_id}"
          end
        end
      end
    end
    def self.exit_on_failure?
      true
    end
  end
end