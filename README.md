# GitLab Insights Mod for Steampipe

A GitLab dashboarding tool that can be used to view dashboards and reports across all of your GitLab resources.

## Overview

Dashboards can help answer questions like:

- How many projects do I have access to?
- How many issues do I have over N days old across all my projects?
- When was a project last contributed to?
- When was user XYZ last active?

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the GitLab plugin with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install theapsgroup/gitlab
```

Clone:

```sh
git clone https://github.com/graza-io/steampipe-mod-gitlab-insights.git
cd steampipe-mod-gitlab-insights
```

### Usage

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser window at https://localhost:9194. From here, you can view dashboards and reports.

### Credentials

This mod uses the credentials configured in the [Steampipe GitLab plugin](https://hub.steampipe.io/plugins/theapsgroup/gitlab).

### FAQ

Q1: I have multiple GitLab configurations but Steampipe only seems to show results from one of these, how do I show all/more?

A1: As the tables in this mod are unqualified, they will revert to utilising the first connection for the plugin that is loaded - you can utilise a [connection aggregator](https://steampipe.io/docs/managing/connections#using-aggregators) in combination with providing the [search path](https://steampipe.io/docs/guides/search-path) argument to specify which connection(s) you wish to include.