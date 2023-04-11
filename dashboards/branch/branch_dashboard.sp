dashboard "branch_dashboard" {
  title = "GitLab Branch Dashboard"
  tags          = merge(local.branch_common_tags, {type = "Dashboard"})
  documentation = file("./dashboards/branch/docs/branch_dashboard.md")

  input "project_id" {
    placeholder = "Select a project"
    type        = "select"
    query       = query.project_input
    width       = 4
  }

  container {
    card {
      query = query.branch_count
      width = 3
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.branch_protected_count
      width = 3
      args  = {
        project_id = self.input.project_id.value
      }
    }
  }

  container {
    table {
      title = "Branches"
      width = 12
      query = query.branch_table
      args  = {
        project_id = self.input.project_id.value
      }

      column "web_url" {
        display = "none"
      }
      column "Branch" {
        href = "{{.'web_url'}}"
      }
    }
  }
}

# Queries
query "branch_count" {
  sql = <<-EOQ
    select count(*) as "Branches" from gitlab_branch where project_id = $1;
  EOQ
  param "project_id" {}
}

query "branch_protected_count" {
  sql = <<-EOQ
    select 
      'Protected Branches' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'ok'
        else 'alert'
      end as type
    from 
      gitlab_branch 
    where 
      project_id = $1
    and
      protected = true;
  EOQ
  param "project_id" {}
}

query "branch_table" {
  sql = <<-EOQ
    select
      name as "Branch",
      merged as "Is Merged",
      protected as "Is Protected",
      commit_date as "Last Commit Date",
      commit_short_id as "Last Commit",
      web_url
    from
      gitlab_branch
    where
      project_id = $1
  EOQ
  param "project_id" {}
}