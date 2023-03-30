dashboard "group_detail" {
  title         = "GitLab Group Detail"
  tags          = merge(local.group_common_tags, {type = "Detail"})
  documentation = file("./dashboards/group/docs/group_detail.md")

  input "group_id" {
    placeholder = "Select a Group"
    type        = "select"
    query       = query.group_input
    width       = 4
  }

  container {
    card {
      query = query.group_member_count
      width = 2
      args  = {
        group_id = self.input.group_id.value
      }
    }

    card {
      query = query.group_subgroup_count
      width = 2
      args  = {
        group_id = self.input.group_id.value
      }
    }

    card {
      query = query.group_project_total_count
      width = 2
      args  = {
        group_id = self.input.group_id.value
      }
    }
  }

  container {
    table {
      title = "Overview"
      type  = "line"
      width = 4
      query = query.group_overview
      args  = {
        group_id = self.input.group_id.value
      }
    }

    chart {
      title = "Project Associations"
      query = query.group_project_associations
      type  = "donut"
      width = 3
      args  = {
        group_id = self.input.group_id.value
      }

      legend {
        display  = "always"
        position = "top"
      }

      series "count" {
        point "direct" {
          color = "ok"
        }
        point "subgroup" {
          color = "info"
        }
      }
    }
  }
}

# Queries
query "group_input" {
  sql = <<-EOQ
    select
      full_name as label,
      id as value
    from
      gitlab_group
    order by
      full_name;
  EOQ
}

query "group_overview" {
  sql = <<-EOQ
    select
      id as "Group ID",
      full_name as "Name",
      coalesce(description, 'None') as "Description",
      created_at as "Created",
      web_url as "Web Page",
      visibility as "Visibility",
      request_access_enabled as "Access Requests Enabled",
      require_two_factor_authentication as "Require 2FA",
      two_factor_grace_period as "2FA Grace Period",
      project_creation_level as "Project Creation Level"
    from
      gitlab_group
    where
      id = $1
  EOQ
  param "group_id" {}
}

query "group_member_count" {
  sql = <<-EOQ
    select count(*) as "Members" from gitlab_group_member where group_id = $1
  EOQ
  param "group_id" {}
}

query "group_subgroup_count" {
  sql = <<-EOQ
    select count(*) as "Subgroups" from gitlab_group_subgroup where parent_id = $1
  EOQ
  param "group_id" {}
}

query "group_project_associations" {
  sql = <<-EOQ
    with assoc as (
      select case namespace_id when $1 then 'direct' else 'subgroup' end as association
      from gitlab_group_project
      where group_id = $1
    )
    select
      association,
      count(*)
    from assoc
    group by association
  EOQ
  param "group_id" {}
}

query "group_project_total_count" {
  sql = <<-EOQ
    select
      'Total Projects' as label,
      count(*) as value
    from 
      gitlab_group_project
    where 
      group_id = $1
  EOQ
  param "group_id" {}
}
