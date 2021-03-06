module Fastlane
  module Actions
    module SharedValues
      CERT_FILE_PATH = :CERT_FILE_PATH
      CERT_CERTIFICATE_ID = :CERT_CERTIFICATE_ID
    end

    class CertAction < Action
      def self.run(params)
        require 'cert'
        require 'cert/options'

        return if Helper.test?

        FastlaneCore::UpdateChecker.start_looking_for_update('cert')

        begin
          Dir.chdir(FastlaneFolder.path || Dir.pwd) do
            # This should be executed in the fastlane folder

            values = params.first
            unless values.kind_of?Hash
              # Old syntax
              values = {}
              params.each do |val|
                values[val] = true
              end
            end

            Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, (values || {}))

            Cert::CertRunner.run
            cert_file_path = ENV["CER_FILE_PATH"]
            certificate_id = ENV["CER_CERTIFICATE_ID"]
            Actions.lane_context[SharedValues::CERT_FILE_PATH] = cert_file_path
            Actions.lane_context[SharedValues::CERT_CERTIFICATE_ID] = certificate_id

            Helper.log.info("Use signing certificate '#{certificate_id}' from now on!".green)

            ENV["SIGH_CERTIFICATE_ID"] = certificate_id
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('cert', Cert::VERSION)
        end
      end

      def self.description
        "Fetch or generate the latest available code signing identity"
      end

      def self.available_options
        require 'cert'
        require 'cert/options'
        Cert::Options.available_options
      end

      def self.author
        "KrauseFx"
      end
    end
  end
end
