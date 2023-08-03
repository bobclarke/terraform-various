provider "github" {
  version = "~> 5.0"
  token   = data.vault_generic_secret.github.data["github_tf_migration_token"]
}