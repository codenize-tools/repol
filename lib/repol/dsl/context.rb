class Repol::DSL::Context
  include Repol::DSL::TemplateHelper

  def self.eval(dsl, path, options = {})
    self.new(path, options) {
      eval(dsl, binding, path)
    }
  end

  def result
    @result.sort_array!
  end

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}

    @context = Hashie::Mash.new(
      :path => path,
      :options => options,
      :templates => {}
    )

    instance_eval(&block)
  end

  def template(name, &block)
    @context.templates[name.to_s] = block
  end

  private

  def require(file)
    repolfile = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(repolfile)
      instance_eval(File.read(repolfile), repolfile)
    elsif File.exist?(repolfile + '.rb')
      instance_eval(File.read(repolfile + '.rb'), repolfile + '.rb')
    else
      Kernel.require(file)
    end
  end

  def repository(name)
    name = name.to_s

    if @result[name]
      raise "Repository `#{name}` is already defined"
    end

    @result[name] = yield
  end
end
