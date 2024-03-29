locals {
  schemas    = [
                 "PRIVATE",
                 "PUBLIC",
                 "MY_SCHEMA",
               ]
  privileges = [
                 "CREATE TABLE",
                 "CREATE VIEW",
                 "USAGE",
               ]

  # Nested loop over both lists, and flatten the result.
  schema_privileges = distinct(flatten([
    for schema in local.schemas : [
      for privilege in local.privileges : {
        privilege = privilege
        schema    = schema
      }
    ]
  ]))
}