# frozen_string_literal: true
require_relative '../json/version'

module Logging
  module Plugins
    module Json
      # This method will be called by the Logging framework when it first
      # initializes. Here we require the json layout code.
      def initialize_json
        require_relative '../layouts/json'
      end

      module_function :initialize_json
    end
  end
end
