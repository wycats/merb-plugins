module Spec
  module Merb
    module DSL
      # Model examples live in $RAILS_ROOT/spec/models/.
      #
      # Model examples use Spec::Merb::DSL::ModelBehaviour, which
      # provides support for fixtures and some custom expectations via extensions
      # to ActiveRecord::Base.
      class ModelBehaviour < Spec::DSL::Behaviour
        def before_eval # :nodoc:
          inherit Spec::Merb::DSL::EvalModule
          configure
        end
      end
    end
  end
end
