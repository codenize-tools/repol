class Repol::Client
  include Repol::Utils::Helper
  include Repol::Logger::Helper

  def initialize(options = {})
    @options = options
    @client = @options[:client] || Aws::ECR::Client.new
    @driver = Repol::Driver.new(@client, @options)
    @exporter = Repol::Exporter.new(@client, @options)
  end

  def export
    @exporter.export
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual = @exporter.export

    updated = walk_repositories(expected, actual)

    if @options[:dry_run]
      false
    else
      updated
    end
  end

  def walk_repositories(expected, actual)
    updated = false

    expected.each do |repository_name,  expected_policy|
      next unless matched?(repository_name)

      actual_policy = actual[repository_name]

      if actual_policy
        updated = walk_policy(repository_name, expected_policy, actual_policy) || updated
      elsif actual.has_key?(repository_name)
        actual.delete(repository_name)

        if expected_policy
          @driver.create_policy(repository_name, expected_policy)
          updated = true
        end
      else
        log(:warn, "No such repository: #{repository_name}")
      end
    end

    updated
  end

  def walk_policy(repository_name, expected_policy, actual_policy)
    updated = false

    if expected_policy
      if expected_policy != actual_policy
        @driver.update_policy(repository_name, expected_policy, actual_policy)
        updated = true
      end
    else
      @driver.delete_policy(repository_name)
      updated = true
    end

    updated
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Repol::DSL.parse(f.read, file)
      end
    elsif file.respond_to?(:read)
      Repol::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
