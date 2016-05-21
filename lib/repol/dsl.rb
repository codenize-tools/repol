class Repol::DSL
  class << self
    def convert(exported, options = {})
      Repol::DSL::Converter.convert(exported, options)
    end

    def parse(dsl, path, options = {})
      Repol::DSL::Context.eval(dsl, path, options).result
    end
  end # of class methods
end
