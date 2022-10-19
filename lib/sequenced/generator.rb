module Sequenced
  class Generator
    attr_reader :record, :scope, :column, :start_at, :skip

    def initialize(record, options = {})
      @record = record
      @scope = options[:scope]
      @column = options[:column].to_sym
      @start_at = options[:start_at]
      @skip = options[:skip]
    end

    def set
      return if skip? || id_set?
      lock_table
      record.send(:"#{column}=", next_id)
    end

    def id_set?
      !record.send(column).nil?
    end

    def skip?
      skip&.call(record)
    end

    def next_id
      next_id_in_sequence.tap do |id|
        id += 1 until unique?(id)
      end
    end

    def next_id_in_sequence
      start_at = self.start_at.respond_to?(:call) ? self.start_at.call(record) : self.start_at
      if (last_record = find_last_record)
        max(last_record.send(column) + 1, start_at)
      else
        start_at
      end
    end

    def unique?(id)
      build_scope(*scope) do
        rel = base_relation
        rel = rel.where.not(record.class.primary_key => record.id) if record.persisted?
        rel.where(column => id)
      end.count == 0
    end

    private

    def lock_table
      return unless postgresql?

      build_scope(*scope) { base_relation.select(1).lock(true) }.load
    end

    def postgresql?
      defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
        record.class.connection.is_a?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    end

    def base_relation
      record.class.base_class.unscoped
    end

    def find_last_record
      build_scope(*scope) do
        base_relation
          .where("#{column} IS NOT NULL")
          .order("#{column} DESC")
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
