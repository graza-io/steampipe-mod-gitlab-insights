dashboard "issue_dashboard" {
  title         = "GitLab Issues Dashboard"
  tags          = merge(local.issue_common_tags, {type = "Dashboard"})
  documentation = file("./dashboards/issue/docs/issue_dashboard.md")

  input "project_id" {
    placeholder = "Select a project"
    type        = "select"
    query       = query.project_input
    width       = 4
  }

  container {
    card {
      query = query.project_issue_count
      width = 3
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.issue_open_count
      width = 3
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.issue_open_over_14_days_count
      width = 3
      args  = {
        project_id = self.input.project_id.value
      }
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Issues by State"
      query = query.issue_by_state
      width = 2
      type  = "donut"
      args  = {
        project_id = self.input.project_id.value
      }

      series "count" {
        point "closed" {
          color = "ok"
        }
        point "opened" {
          color = "alert"
        }
      }
    }

    chart {
      title    = "Issues by Age"
      type     = "column"
      width    = 4
      query    = query.issue_by_age
      args = {
        project_id = self.input.project_id.value
      }

      series closed {
        title = "Closed"
        color = "ok"
      }
      series opened {
        title = "Open"
        color = "alert"
      }
    }
  }

  container {
    table {
      title = "Issues"
      width = 12
      query = query.issue_table
      args  = {
        project_id = self.input.project_id.value
      }

      column "web_url" {
        display = "none"
      }
      column "Issue" {
        href = "{{.'web_url'}}"
      }
    }
  }
}

# Queries
query "issue_open_count" {
  sql = <<-EOQ
    select count(*) as "Open" from gitlab_issue where project_id = $1 and state = 'opened'; 
  EOQ
  param "project_id" {}
}

query "issue_open_over_14_days_count" {
  sql = <<-EOQ
    select
      'Open > 14 days' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      gitlab_issue
    where
      project_id = $1
    and
      state = 'opened'
    and
      created_at <= (current_date - interval '14' day);
  EOQ
  param "project_id" {}
}

query "issue_by_state" {
  sql = <<-EOQ
    select
      state as "State",
      count(*)
    from
      gitlab_issue
    where
      project_id = $1
    group by
      state;
  EOQ
  param "project_id" {}
}

query "issue_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at, 'YYYY-MM') as created,
      state,
      count(*) as total
    from
      gitlab_issue
    where
      project_id = $1
    group by
      state,
      created;
  EOQ
  param "project_id" {}
}

query "issue_table" {
  sql = <<-EOQ
    select
      id as "Issue",
      title as "Title",
      author as "Author",
      now()::date - created_at::date as "Days since created",
      now()::date - updated_at::date as "Days since last updated",
      full_ref as "Reference",
      web_url
    from
      gitlab_issue
    where
      project_id = $1
    order by
      created_at;
  EOQ
  param "project_id" {}
}