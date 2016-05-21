class Repol::Exporter
  include Repol::Utils::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def export
    export_repositories.sort_array!
  end

  private

  def export_repositories
    result = {}
    repositories = get_repositories
    concurrency = @options[:request_concurrency]

    Parallel.each(repositories, in_threads: concurrency) do |repository|
      name = repository.repository_name
      next unless matched?(name)
      policy = export_repository_policy(repository)
      result[name] = policy
    end

    result
  end

  def export_repository_policy(repository)
    name = repository.repository_name
    resp = @client.get_repository_policy(repository_name: name)
    JSON.parse(resp.policy_text)
  rescue Aws::ECR::Errors::RepositoryPolicyNotFoundException
    nil
  end

  def get_repositories
    repositories = []
    next_token = nil

    loop do
      resp = @client.describe_repositories(next_token: next_token)
      repositories.concat(resp.repositories)
      next_token = resp.next_token
      break unless next_token
    end

    repositories
  end
end
