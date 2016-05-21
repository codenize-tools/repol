class Repol::Driver
  include Repol::Utils::Helper
  include Repol::Logger::Helper

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def create_policy(repository_name, policy)
    log(:info, "Create Repository `#{repository_name}` Policy", color: :cyan)

    unless @options[:dry_run]
      @client.set_repository_policy(
        repository_name: repository_name,
        policy_text: JSON.dump(policy)
      )
    end
  end

  def delete_policy(repository_name)
    log(:info, "Delete Repository `#{repository_name}` Policy", color: :red)

    unless @options[:dry_run]
      @client.delete_repository_policy(
        repository_name: repository_name
      )
    end
  end

  def update_policy(repository_name, policy, old_policy)
    log(:info, "Update Repository `#{repository_name}` Policy", color: :green)
    log(:info, diff(old_policy, policy, color: @options[:color]), color: false)

    unless @options[:dry_run]
      @client.set_repository_policy(
        repository_name: repository_name,
        policy_text: JSON.dump(policy)
      )
    end
  end
end
