require 'json'

module RspecFlaky
  class FlakyExamplesCollection < SimpleDelegator
    def self.from_json(json)
      new(JSON.parse(json))
    end

    def initialize(collection = {})
      unless collection.is_a?(Hash)
        raise ArgumentError, "`collection` must be a Hash, #{collection.class} given!"
      end

      collection_of_flaky_examples =
        collection.map do |uid, example|
          [
            uid,
            example.is_a?(RspecFlaky::FlakyExample) ? example : RspecFlaky::FlakyExample.new(example)
          ]
        end

      super(Hash[collection_of_flaky_examples])
    end

    def to_report
      Hash[map { |uid, example| [uid, example.to_h] }].deep_symbolize_keys
    end

    def -(other)
      unless other.respond_to?(:key)
        raise ArgumentError, "`other` must respond to `#key?`, #{other.class} does not!"
      end

      self.class.new(reject { |uid, _| other.key?(uid) })
    end
  end
end
