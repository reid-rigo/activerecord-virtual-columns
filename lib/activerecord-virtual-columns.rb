require 'active_record'

module ActiveRecord
  module VirtualColumns
    extend ActiveSupport::Concern

    included do
      class_attribute :virtual_columns, default: HashWithIndifferentAccess.new

      scope :with_vcolumns, ->(*cols, select: :*) {
        sql = cols.map do |c|
          raise "No virtual column #{c}!" unless virtual_columns[c]

          scope = virtual_columns[c].call
          snippet = scope.is_a?(String) ? scope : scope.to_sql
          "(#{snippet}) AS \"#{c}\""
        end.join(', ')
        select == :* ? select("#{base_class.table_name}.*, #{sql}") : select(sql)
      }
    end

    class_methods do
      def virtual_column(name, params = { scope: nil, method: nil, transform: nil })
        virtual_columns[name] = params[:scope]

        define_method(name) do
          if has_attribute?(name)
            if params[:transform]
              params[:transform].call self[name]
            else
              self[name]
            end
          elsif params[:method]
            instance_exec(&params[:method])
          else
            raise MethodNotImplementedError.new(name)
          end
        end
      end
    end

    class MethodNotImplementedError < StandardError
      def initialize(column)
        super("#{column} has no method provided - you must use the scope")
      end
    end
  end
end