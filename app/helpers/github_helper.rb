module GithubHelper

  # URL to page with recent changes until the given version
  def github_changes_url(commit=Rails.application.current_commit)
    github_url "commits/#{commit}"
  end

  # URL to page with changes from the given version to upstream release
  def github_updates_url(upstream='master', commit=Rails.application.current_commit)
    github_url "compare/#{commit}...#{upstream}"
  end

  def github_issues_url
    github_url 'issues'
  end

  def github_url(path)
    %Q~https://github.com/niklas/cataract/#{path}~
  end
end
