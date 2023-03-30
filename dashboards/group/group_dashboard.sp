dashboard "group_dashboard" {
  title         = "GitLab Group Dashboard"
  tags          = merge(local.group_common_tags, {type = "Dashboard"}) 
  documentation = file("./dashboards/group/docs/group_dashboard.md")

  container {
    card {
      query = query.group_count
      width = 2
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Groups by Visibility"
      type  = "column"
      width = 2
      query = query.groups_by_visibility
    }

    chart {
      title = "Groups by Age"
      type  = "column"
      width = 6
      query = query.groups_by_age
    }
  }
}

# Queries
query "group_count" {
  sql = <<-EOQ
    select count(*) as "Groups" from gitlab_group;
  EOQ
}

query "groups_by_visibility" {
  sql = <<-EOQ
    select 
      visibility as "Visibility",
      count(*) as "Groups"
    from
      gitlab_group
    group by
      visibility
    order by
      visibility desc;
  EOQ
}

query "groups_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at, 'YYYY-MM') as creation_month,
      count(*) as "Groups"
    from
      gitlab_group
    group by creation_month;
  EOQ
}