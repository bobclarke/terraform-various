locals {
  github_token                  = var.github_token
  waf_rules_override_branch     = ""
  waf_rules_branch              = "main"
  waf_rules_override_branch_obj = local.waf_rules_override_branch != "" ? { for obj in split(",", local.waf_rules_override_branch) : element(split(":", obj), 0) => element(split(":", obj), 1) } : {}
  per_listener_git_branch       = { for repo in data.github_repositories.repo_list.full_names :
    repo => lookup(local.waf_rules_override_branch_obj, repo, local.waf_rules_branch)
  }
}

data "github_repositories" "repo_list" {
  query = "org:gdo-secops topic:waf-enabled"
}

data "github_repository" "repo" {
  for_each  = toset(data.github_repositories.repo_list.full_names)
  full_name = each.key

  depends_on = [data.github_repositories.repo_list]
}

data "github_repository_file" "waf_config" {
  for_each   = toset(data.github_repositories.repo_list.full_names)
  repository = data.github_repository.repo[each.key].full_name
  branch     = local.per_listener_git_branch[each.key]
  file       = "config.json"

  depends_on = [
    data.github_repository.repo
  ]
}