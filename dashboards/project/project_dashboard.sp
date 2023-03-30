dashboard "project_dashboard" {
  title         = "GitLab Project Dashboard"
  tags          = merge(local.project_common_tags, {type = "Dashboard"})
  documentation = file("./dashboards/project/docs/project_dashboard.md")

  container {
    title = "Key Information"
        
    card {
      query = query.project_count
      width = 2
    }

    card {
      query = query.archived_project_count
      width = 2
    }

    card {
      query = query.public_project_count
      width = 2
    }

    card {
      query = query.empty_repo_project_count
      width = 2
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Projects by Visibility"
      type  = "column"
      width = 2
      query = query.project_by_visibility
    }

    chart {
      title = "Projects by Age"
      type  = "column"
      width = 6
      query = query.project_by_age
    }
  }
}

# Queries
query "project_count" {
  sql = <<-EOQ
    select count(*) as "Projects" from gitlab_my_project;
  EOQ
}

query "public_project_count" {
  sql = <<-EOQ
    select
      'Public Projects' as label, 
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from 
      gitlab_my_project 
    where 
      public = true;
  EOQ
}

query "archived_project_count" {
  sql = <<-EOQ
    select 
      count(*) as "Archived Projects"
    from
      gitlab_my_project
    where
      archived = true;
  EOQ
}

query "empty_repo_project_count" {
  sql = <<-EOQ
    select
      'Empty Projects' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      gitlab_my_project
    where
      empty_repo = true;
  EOQ
}

query "project_by_visibility" {
  sql = <<-EOQ
    select
      visibility as "Visibility",
      count(*) as "Projects"
    from
      gitlab_my_project
    group by 
      visibility
    order by
      visibility desc;
  EOQ
}

query "project_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at, 'YYYY-MM') as creation_month,
      count(*) as "Projects"
    from
      gitlab_my_project
    group by creation_month;
  EOQ
}