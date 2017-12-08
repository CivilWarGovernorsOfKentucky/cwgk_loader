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
        Utils.logger.info "Upload files in #{ENV['GIT_ROOT_DIR']}/xml that is updated less than 1 day ago"
        files_modified = Dir["#{ENV['GIT_ROOT_DIR']}/xml/*.xml"].select { |f| File.file?(f) and File.mtime(f) > (Time.now - 60*60*24*1) }
        files_modified.each do |xml_file|
          doc_id = File.basename(xml_file)
          Utils.logger.info "Uploading #{doc_id}"
          if doc_id.start_with? 'KYR'
            submitter.submit_document xml_file
          elsif 'NOPG'.include? doc_id[0]
            submitter.submit_entity xml_file
          else
            Utils.logger.error "Invalid filename: #{doc_id}.xml"
          end
        end
      else
        doc_id.split(':').each do |doc_id|
          filename = doc_id.end_with?('.xml')? doc_id : doc_id + '.xml'
          Utils.logger.info "Uploading #{filename}"
          if doc_id.start_with? 'KYR'
            submitter.submit_document "#{ENV['GIT_ROOT_DIR']}/xml/#{filename}"
          elsif 'NOPG'.include? doc_id[0]
            submitter.submit_entity "#{ENV['GIT_ROOT_DIR']}/xml/#{filename}"
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
