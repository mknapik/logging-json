# frozen_string_literal: true
require_relative 'version'

module Logging
  module Plugins
    module Json
      # This method will be called by the Logging framework when it first
      # initializes. Here we require the email appender code.
      def initialize_json
        require_relative '../layouts/json'
      end

      module_function :initialize_json
    end
  end
end
