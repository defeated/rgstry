require 'octokit'
require 'bundler'
require 'base64'

class HomeController < ApplicationController
  def index

    @programs = []

    # connect to the mothership
    github = Octokit::Client.new({
      login:        ENV['GITHUB_LOGIN'],
      oauth_token:  ENV['GITHUB_OAUTH_TOKEN']
    })

    # get all our repositories that identify as ruby
    ruby_repos = github.org_repos( ENV['GITHUB_ORG'] ).select do |repo|
      repo.language == "Ruby"
    end

    # get most recent commit of the master branch
    ruby_repos.each do |repo|
      master = github.branch repo.full_name, "master"

      # fetch gemfile.lock if it exists
      begin
        gemfile     = github.contents repo.full_name, path: 'Gemfile.lock'
        gemfile_raw = Base64.decode64 gemfile.content
        parsed      = Bundler::LockfileParser.new gemfile_raw

        # check if rails is used
        if rails = parsed.dependencies.find { |dep| dep.name == 'rails' }
          program = Program.new({
            name:         repo.full_name,
            description:  repo.description,
            rails:        rails.requirement,
            revision:     master.commit.sha,
            committed_at: master.commit.commit.committer.date
          })

          @programs << program
        end
      rescue
      end
    end

  end
end