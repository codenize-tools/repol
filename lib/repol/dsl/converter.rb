class Repol::DSL::Converter
  include Repol::Utils::Helper

  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_repositories(@exported)
  end

  private

  def output_repositories(policy_by_repository)
    repositories = []

    policy_by_repository.sort_by(&:first).each do |repository_name, policy|
      if not policy or not matched?(repository_name)
        next
      end

      repositories << output_repository(repository_name, policy)
    end

    repositories.join("\n")
  end

  def output_repository(repository_name, policy)
    policy = policy.pretty_inspect.gsub(/^/, '  ').strip

    <<-EOS
repository #{repository_name.inspect} do
  #{policy}
end
    EOS
  end
end
