# frozen_string_literal: true
require 'logging'
require_relative '../json/version'

module Logging
  module Layouts
    class Json < ::Logging::Layouts::Parseable
      def initialize(opts = {})
        opts[:style] = 'json'
        super(opts)
      end

      def format(event)
        result = {
          'logger' => event.logger,
          'timestamp' => iso8601_format(event.time),
          'level' => ::Logging::LNAMES[event.level]
        }
        result.merge!(log_hash(event))
        MultiJson.encode(result) << "\n"
      end

      private

      def log_hash(event)
        formatted = recursive_format(event.data)
        formatted.is_a?(Hash) ? formatted : {'message' => formatted}
      end

      def recursive_format(obj)
        case obj
        when Hash
          format_hash(obj)
        when Exception
          format_exception(obj)
        when Time
          iso8601_format(obj)
        else
          format_obj(obj)
        end
      end

      def format_hash(obj)
        obj.each_with_object({}) do |(key, value), result|
          result[key] = recursive_format(value)
        end
      end

      def format_exception(exception)
        result = {
          'exception' => exception.class.name,
          'message' => format_obj(exception.message)
        }
        result['cause'] = format_exception(exception.cause) if exception.cause
        result['backtrace'] = exception.backtrace if @backtrace && exception.backtrace
        result
      end

      # original `create_format_method` overrides `format` method with meta-programming
      def create_format_method
      end
    end
  end
end
