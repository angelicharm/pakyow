# frozen_string_literal: true

require "pakyow/support/aargv"
require "pakyow/core/routing/hook_merger"

module Pakyow
  module Routing
    # A route, consisting of a name, path, and pipeline. The pipeline is a list
    # of procs and/or method names that are called in order when the route is
    # matched and executed. Pipelines are constructed at runtime.
    #
    class Route
      include HookMerger

      attr_reader :matcher, :path, :method, :name, :block, :hooks, :pipeline

      def initialize(path_or_matcher, name: nil, method: nil, hooks: {}, skips: {}, &block)
        @name, @method, @hooks, @skips, @block = name, method, hooks, skips, block

        if path_or_matcher.is_a?(String)
          @path    = path_or_matcher
          @matcher = create_matcher_from_path(@path)
        else
          @path    = ""
          @matcher = path_or_matcher
        end

        # TODO: pass input
        @pipeline = compile_pipeline
      end

      # TODO: this logic can be shared with router
      def match(path_to_match)
        matcher.match(path_to_match)
      end

      def call(context)
        @pipeline.each do |pipeline_part|
          if pipeline_part.is_a?(Proc)
            context.instance_exec(&pipeline_part)
          elsif pipeline_part.is_a?(Hook)
            next if pipeline_part.skip?(self, context) || skip?(pipeline_part)
            pipeline_part.call_in_context(context)
          else
            context.__send__(pipeline_part)
          end
        end
      end

      def populated_path(path_to_self, **params)
        String.normalize_path(File.join(path_to_self.to_s, path.to_s).split("/").map { |path_segment|
          if path_segment[0] == ":"
            params[path_segment[1..-1].to_sym]
          else
            path_segment
          end
        }.join("/"))
      end

      protected

      def create_matcher_from_path(path)
        converted_path = String.normalize_path(path.split("/").map { |segment|
          if segment.include?(":")
            "(?<#{segment[1..-1]}>(\\w|[-.~:@!$\\'\\(\\)\\*\\+,;])*)"
          else
            segment
          end
        }.join("/"))

        Regexp.new("^#{converted_path}$")
      end

      def compile_pipeline
        [
          hooks[:around],
          hooks[:before],
          block,
          hooks[:after],
          hooks[:around]
        ].flatten.compact
      end

      def skip?(hook)
        @skips[:all].include?(hook.name) || @skips[hook.type].include?(hook.name)
      end
    end
  end
end
