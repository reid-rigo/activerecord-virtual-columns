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
      def virtual_column(name, params = { scope: nil, method: nil })
        virtual_columns[name] = params[:scope]

        define_method(name) do
          if has_attribute?(name)
            self[name]
          else
            instance_exec(&params[:method])
          end
        end
      end
    end

  end
end