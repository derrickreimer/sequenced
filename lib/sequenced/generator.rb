module Sequenced
  class Generator
    attr_reader :record, :scope, :column, :start_at, :skip

    def initialize(record, options = {})
      @record = record
      @scope = options[:scope]
      @column = (options[:column] || :sequential_id).to_sym
      @start_at = options[:start_at] || 1
      @skip = options[:skip]
    end

    def set
      record.send(:"#{column}=", next_id) unless id_set? || skip?
    end

    def id_set?
      !record.send(column).nil?
    end

    def skip?
      skip && skip.call(record)
    end

    def next_id
      next_id_in_sequence.tap do |id|
        id += 1 until unique?(id)
      end
    end

    def next_id_in_sequence
      return start_at unless last_record = find_last_record
      max(last_record.send(column) + 1, start_at)
    end

    def unique?(id)
      build_scope(*scope) do
        rel = base_relation
        rel = rel.where("NOT id = ?", record.id) if record.persisted?
        rel.where(column => record.send(column))
      end.count == 0
    end

  private

    def base_relation
      record.class.unscoped
    end

    def find_last_record
      build_scope(*scope) do
        base_relation.
        where("#{column.to_s} IS NOT NULL").
        order("#{column.to_s} DESC")
      end.first
    end

    def build_scope(*columns)
      rel = yield
      columns.each { |c| rel = rel.where(c => record.send(c.to_sym)) }
      rel
    end

    def max(*values)
      values.to_a.max
    end

  end
end