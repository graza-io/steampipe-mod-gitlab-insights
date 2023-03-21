mod "gitlab_insights" {
  title       = "GitLab Insights"
  description = "Dashboards and reports for GitLab resources."
  color       = "#FCA121"
  categories  = ["gitlab", "dashboard"]

  require {
    steampipe = "0.19.2"
    #plugin "github.com/theapsgroup/gitlab" {
    #  version = "0.3.0"
    #}
  }
}
