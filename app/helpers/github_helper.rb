module GithubHelper

  # URL to page with recent changes until the given version
  def github_changes_url(commit=current_commit)
    %Q~https://github.com/niklas/cataract/commits/#{commit}~
  end

  # URL to page with changes from the given version to upstream release
  def github_updates_url(upstream='master', commit=current_commit)
    %Q~https://github.com/niklas/cataract/compare/#{commit}...#{upstream}~
  end

  def current_commit
    @current_commit ||= `git log -1 HEAD --format=format:%H`.chomp
  end
end
