class AddTypeToSource < ActiveRecord::Migration[5.0]
  def change
    add_column :sources, :source_type, :string
  end
end
