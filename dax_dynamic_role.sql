

--DAX SCRIPT TO USE DYNAMIC RLS
--On DAX Filter of "TableName"

= CONTAINS (
    role_table_name,
    role_table_name[user_name_col], USERNAME(),
    role_table_name[col_name], TableName[col_name]
)