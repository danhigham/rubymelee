Sequel.migration do
  up do
    create_table(:melees) do
      primary_key :id
      String :guid, :null=>false
      String :content
      String :container_handle
    end
  end

  down do
    drop_table(:melees)
  end
end
