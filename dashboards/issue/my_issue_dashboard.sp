dashboard "my_issue_dashboard" {
  title         = "GitLab My Issues Dashboard"
  tags          = merge(local.issue_common_tags, {type = "Dashboard"})
  documentation = file("./dashboards/issue/docs/my_issue_dashboard.md")

  container {
    card {
      query = query.my_issue_count
      width = 2
    }

    card {
      query = query.my_issue_open_count
      width = 2
    }

    card {
      query = query.my_issue_open_longer_than_14_days
      width = 2
    }
  }

  container {
    title = "Analysis"

    chart {
      title = "Issues by Age"
      type  = "column"
      width = 4
      query = query.my_issue_by_age

      series closed {
        title = "Closed"
        color = "ok"
      }

      series opened {
        title = "Open"
        color = "alert"
      }
    }

    chart {
      title = "Issues by State"
      type  = "donut"
      width = 4
      query = query.my_issue_by_state

      series "count" {
        point "opened" {
          color = "alert"
        }
        point "closed" {
          color = "ok"
        }
      }
    }
  }

  container {
    table {
      title = "Open Issues"
      width = 12
      query = query.my_issue_table

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
query "my_issue_count" {
  sql = <<-EOQ
    select count(*) as "Issues" from gitlab_my_issue;
  EOQ
}

query "my_issue_open_count" {
  sql = <<-EOQ
    select
      'Open Issues' as label,
      count(*) as value,
      case
        when count(*) > 10 then 'alert'
        when count(*) > 5 then 'info'
        else 'ok'
      end as type
    from
      gitlab_my_issue
    where
      state = 'opened';
  EOQ
}

query "my_issue_open_longer_than_14_days" {
  sql = <<-EOQ
    select
      'Open > 14 days' as label,
      count(*) as value,
      case
        when count(*) > 0 then 'alert'
        else 'ok'
      end as type
    from
      gitlab_my_issue
    where
      state = 'opened' and
      created_at <= (current_date - interval '14' day);
  EOQ
}

query "my_issue_by_age" {
  sql = <<-EOQ
    select
      to_char(created_at, 'YYYY-MM') as created,
      state,
      count(*) as total
    from
      gitlab_my_issue
    group by
      state,
      created;
  EOQ
}

query "my_issue_by_state" {
  sql = <<-EOQ
    select state as "State", count(*) from gitlab_my_issue group by state;
  EOQ
}

query "my_issue_table" {
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
      gitlab_my_issue
    where
      state = 'opened'
    order by created_at;
  EOQ
}