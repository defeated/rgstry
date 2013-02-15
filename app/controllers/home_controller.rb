require 'octokit'
require 'bundler'
require 'base64'
require 'gems'

class HomeController < ApplicationController
  def index

    @versions = Gems.versions('rails').
      reject { |version| version['prerelease'] }.take(4).
      map { |version| version["number"] }.sort.reverse

    @programs = []

    # connect to the mothership
    github = Octokit::Client.new({
      login:        ENV['GITHUB_LOGIN'],
      oauth_token:  ENV['GITHUB_OAUTH_TOKEN']
    })

    # repos by org or by user
    available_repos = if org = ENV['GITHUB_ORG']
      github.org_repos org
    elsif user = ENV['GITHUB_USER']
      github.list_repos user
    end

    # get all repositories that identify as ruby
    ruby_repos = available_repos.select do |repo|
      repo.language == "Ruby"
    end

    # get most recent commit of the master branch
    ruby_repos.each do |repo|
      master = github.branch repo.full_name, "master"

      # fetch gemfile.lock if it exists
      begin
        gemfile = github.contents repo.full_name, path: 'Gemfile.lock'
      rescue Octokit::NotFound
        next
      end

      # parse gemfile.lock
      gemfile_raw = Base64.decode64 gemfile.content
      parsed      = Bundler::LockfileParser.new gemfile_raw

      # check if rails is used
      if rails = parsed.dependencies.find { |dep| dep.name == 'rails' }
        program = Program.new({
          name:         repo.full_name,
          description:  repo.description,
          rails:        rails.requirement.requirements.first.last.version,
          revision:     master.commit.sha,
          committed_at: master.commit.commit.committer.date
        })

        @programs << program
      end
    end

  end
end
