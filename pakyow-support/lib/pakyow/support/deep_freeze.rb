module Pakyow
  module Support
    module DeepFreeze
      refine Object.singleton_class do
        def unfreezable_variables
          @unfreezable_variables ||= []
        end

        private

        def unfreezable(*ivars)
          ivars = ivars.map { |ivar| "@#{ivar}".to_sym }
          unfreezable_variables.concat(ivars)
          unfreezable_variables.uniq!
        end
      end

      refine Object do
        def deep_freeze
          return self if frozen?

          self.freeze

          freezable_variables.each do |name|
            instance_variable_get(name).deep_freeze
          end

          self
        end

        private

        def freezable_variables
          instance_variables - self.class.unfreezable_variables
        end
      end

      refine Array do
        def deep_freeze
          return self if frozen?

          self.freeze

          each(&:deep_freeze)

          self
        end
      end
    end
  end
end

