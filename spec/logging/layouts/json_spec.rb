# frozen_string_literal: true
require 'spec_helper'
require 'logging/layouts/json'
require 'json'

RSpec.describe Logging::Layouts::Json do
  let(:layout) { described_class.new }
  let(:logger) { double }
  let(:level) { 0 }
  let(:caller_tracing) { double }
  let(:event) { Logging::LogEvent.new(logger, level, data, caller_tracing) }

  before { stub_const('Logging::LNAMES', ['level_name']) }

  describe '#format' do
    subject { layout.format(event) }
    let(:subject_json) { JSON.parse(subject) }

    context 'when argument is string' do
      let(:data) { 'something happened' }

      it 'shows data as message field' do
        expect(subject_json).to include('message' => data)
      end
    end

    context 'when argument is time' do
      let(:data) { Time.parse('2015-02-10 23:20:31 UTC').utc }

      it 'shows formatted time as message field' do
        expect(Time.iso8601(subject_json['message'])).to eq(data)
      end
    end

    context 'when argument is error' do
      context 'when error has no message' do
        let(:data) { StandardError.new }

        it 'shows error class as exception field' do
          expect(subject_json).to include('exception' => data.class.name)
        end

        it 'shows error class as message field' do
          expect(subject_json).to include('message' => data.class.name)
        end
      end

      context 'when error has message' do
        let(:message) { 'something bad happened' }
        let(:data) { StandardError.new(message) }

        it 'shows error class as exception field' do
          expect(subject_json).to include('exception' => data.class.name)
        end

        it 'shows error message as message field' do
          expect(subject_json).to include('message' => message)
        end
      end

      context 'when wrapping error has cause exception' do
        let(:original_error_message) { 'cause error' }
        let(:original_error) { StandardError.new(original_error_message) }
        let(:wrapping_error) { StandardError.new }
        let(:wrapping_error_with_cause_original_error) do
          begin
            begin
              raise original_error
            rescue
              raise wrapping_error
            end
          rescue => wrapping_error
            wrapping_error
          end
        end
        let(:data) { wrapping_error_with_cause_original_error }

        it 'shows error class as exception field' do
          expect(subject_json).to include('exception' => data.class.name)
        end

        it 'has cause error field' do
          expect(subject_json).to include('cause')
        end

        it 'shows error class of original error' do
          expect(subject_json['cause']).to include('exception' => original_error.class.name)
        end

        it 'shows error message of original error' do
          expect(subject_json['cause']).to include('message' => original_error_message)
        end
      end
    end

    context 'when argument is a hash' do
      let(:tag1) { :tag1 }
      let(:data) { {tag1 => value1} }

      context 'when hash value is a string' do
        let(:value1) { 'value1' }

        it 'shows value in tag field' do
          expect(subject_json).to include('tag1' => value1)
        end

        it 'does not have message' do
          expect(subject_json).not_to include('message')
        end
      end

      context 'when hash value is time' do
        let(:value1) { Time.parse('2015-02-05 13:54:12 UTC').utc }

        it 'shows formatted time as tag field' do
          expect(Time.iso8601(subject_json['tag1'])).to eq(value1)
        end

        it 'does not have message' do
          expect(subject_json).not_to include('message')
        end
      end

      context 'when hash value is an error' do
        let(:message) { 'something bad happened' }
        let(:value1) { StandardError.new(message) }

        it 'presents tag1 field as a hash' do
          expect(subject_json[tag1.to_s]).to be_a(Hash)
        end

        it 'presents error class as in nested tag' do
          expect(subject_json[tag1.to_s]).to include('exception' => value1.class.name)
        end

        it 'presents error message as in nested tag' do
          expect(subject_json[tag1.to_s]).to include('message' => value1.message)
        end
      end

      context 'when hash value is a hash' do
        let(:tag2) { :tag2 }
        let(:tag3) { :tag3 }
        let(:value1) { {tag2.to_s => value2} }
        let(:value2) { {tag3.to_s => value3} }
        let(:value3) { 'value3' }

        it 'presents tag1 field as a hash' do
          expect(subject_json[tag1.to_s]).to be_a(Hash)
        end

        it 'presents value in nested tag' do
          expect(subject_json[tag1.to_s]).to include(tag2.to_s => value2)
        end

        it 'presents value in double nested tag' do
          expect(subject_json[tag1.to_s][tag2.to_s]).to include(tag3.to_s => value3)
        end
      end
    end
  end
end
