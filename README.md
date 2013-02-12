# Rgstry

![Registry Of Things](public/registry.jpg)

  1. query github.com/litmus for repositories
    - exclude repositories where language is not Ruby
    - GitHub API w/ OAuth2 token
      * requires "repo" scope

      ```ruby
      require 'octokit'
      client = Octokit::Client.new login: "u", oauth_token: "x"
      client.org_repos("litmus").select {|repo| repo.language == "Ruby" }
      ...
      master = client.branch "litmus/litmus", "master"
      master.commit.commit.committer.date
      master.commit.sha
      ```

  2. use similar heuristics as Heroku to detect if repo is Rails?
    - https://github.com/heroku/heroku-buildpack-ruby#flow
      * Rails 3 (config/application.rb is detected)
      * Rails 2 (config/environment.rb is detected)

  3. display the following
    - repo name
    - description
    - rails version
    - master branch latest revision
    - master branch latest timestamp
    - wishful thinking:
      * build status
      * click to deploy
