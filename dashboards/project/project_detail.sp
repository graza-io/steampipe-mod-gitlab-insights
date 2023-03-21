dashboard "project_detail" {
  title = "GitLab Project Detail"
  tags  = merge(local.project_common_tags, {
    type = "Detail"
  })

  input "project_id" {
    placeholder = "Select a project"
    type        = "select"
    query       = query.project_input
    width       = 4
  }

  container {
    card {
      query = query.project_branch_count
      width = 2
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.project_commit_count
      width = 2
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.project_issue_count
      width = 2
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.project_merge_request_count
      width = 2
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.project_job_count
      width = 2
      args  = {
        project_id = self.input.project_id.value
      }
    }

    card {
      query = query.project_status
      width = 2
      args  = {
        project_id = self.input.project_id.value
      }
    }
  }

  container {
    table {
      title = "Overview"
      type  = "line"
      width = 4
      query = query.project_overview
      args  = {
        project_id = self.input.project_id.value
      }
    }

    container {
      width = 8

      
    }
  }

  container {
    table {
      title = "Most Recent Issues"
      width = 6
      query = query.project_recent_issues
      args  = {
        project_id = self.input.project_id.value
      }

      column "web_url" {
        display = "none"
      }

      column "Title" {
        href = "{{.'web_url'}}"
      }
    }

    table {
      title = "Most Recent Commits"
      width = 6
      query = query.project_recent_commits
      args  = {
        project_id = self.input.project_id.value
      }

      column "web_url" {
        display = "none"
      }

      column "Commit" {
        href = "{{.'web_url'}}"
      }

      column "Message" {
        href = "{{.'web_url'}}"
      }
    }
  }
}

query "project_input" {
  sql = <<-EOQ
    select
      full_name as label,
      id as value
    from
      gitlab_my_project
    order by
      full_name;
  EOQ
}

query "project_overview" {
  sql = <<-EOQ
    select
      id as "Project ID",
      full_name as "Name",
      coalesce(description, 'None') as "Description",
      created_at as "Created",
      last_activity_at as "Last Activity",
      coalesce(license, 'None') as "License",
      coalesce(owner_name, 'Not Set') as "Owner",
      web_url as "Web Page",
      ssh_url as "SSH Clone Url",
      http_url as "HTTP Clone Url"
    from
      gitlab_my_project
    where
      id = $1;
  EOQ

  param "project_id" {}
}

query "project_commit_count" {
  sql = <<-EOQ
    select
      'Commits' as label,
      commit_count as value
    from
      gitlab_my_project
    where
      id = $1;
  EOQ

  param "project_id" {}
}

query "project_issue_count" {
  sql = <<-EOQ
    select count(*) as "Issues" from gitlab_issue where project_id = $1;
  EOQ

  param "project_id" {}
}

query "project_branch_count" {
  sql = <<-EOQ
    select count(*) as "Branches" from gitlab_branch where project_id = $1;
  EOQ

  param "project_id" {}
}

query "project_merge_request_count" {
  sql = <<-EOQ
    select count(*) as "Merge Requests" from gitlab_merge_request where project_id = $1;
  EOQ

  param "project_id" {}
}

query "project_job_count" {
  sql = <<-EOQ
    select count(*) as "Jobs" from gitlab_project_job where project_id = $1;
  EOQ

  param "project_id" {}
}

query "project_status" {
  sql = <<-EOQ
    select
      'Status' as label,
      case
        when archived and empty_repo then 'Archived/Empty'
        when archived then 'Archived'
        when empty_repo then 'Empty'
      end as value,
      case
        when not archived and not empty_repo then 'ok'
        else 'alert'
      end as type
    from
      gitlab_my_project
    where
      id = $1;
  EOQ

  param "project_id" {}
}

query "project_commits_by_author_top_10" {
  sql = <<-EOQ
    select
      u.username as author,
      count(c.*) as total
    from
      gitlab_commit c,
      gitlab_user u
    where
      project_id = $1
    and
      c.committer_email = u.email
    group by
      u.username
    order by
      total desc
    limit 10;
  EOQ

  param "project_id" {}
}

query "project_recent_issues" {
  sql = <<-EOQ
    select
      id as "ID",
      title as "Title",
      created_at as "Created",
      web_url
    from
      gitlab_issue 
    where 
      project_id = $1
    order by
      created_at desc
    limit 5;
  EOQ

  param "project_id" {}
}

query "project_recent_commits" {
  sql = <<-EOQ
    select
      short_id as "Commit",
      message as "Message",
      committer_name as "Author",
      created_at as "Created",
      web_url
    from
      gitlab_commit
    where 
      project_id = $1
    order by
      created_at desc
    limit 5;
  EOQ

  param "project_id" {}
}