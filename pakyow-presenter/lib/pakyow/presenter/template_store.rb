# frozen_string_literal: true

require "pakyow/support/deep_freeze"

module Pakyow
  module Presenter
    class TemplateStore
      extend Support::DeepFreeze
      unfreezable :info, :layouts, :partials

      attr_reader :name, :path

      LAYOUTS_PATH = "layouts".freeze
      # TODO: rename this if we keep the include naming
      PARTIALS_PATH = "includes".freeze
      # TODO: rename this
      TEMPLATES_PATH = "pages".freeze

      def initialize(name, path, processor: nil)
        @name, @path, @processor = name, Pathname(path), processor
        load
      end

      def view?(path)
        @info.key?(path)
      end

      def info(path)
        return unless view?(path)

        @info[path].each_with_object({}) { |info_path, info|
          info[info_path[0]] = info_path[1].dup
        }
      end

      def layout(name_or_path)
        if name_or_path.is_a?(Symbol)
          layout_with_name(name_or_path)
        else
          info(name_or_path) & [:template]
        end
      end

      def page(path)
        info(path) & [:page]
      end

      def partials(path)
        info(path) & [:partials] || {}
      end

      def partial(path, name)
        partials(path)[name.to_sym]
      end

      private

      def layouts_path
        path.join(LAYOUTS_PATH)
      end

      def partials_path
        path.join(PARTIALS_PATH)
      end

      def templates_path
        path.join(TEMPLATES_PATH)
      end

      def layout_with_name(name)
        load_layouts

        unless layout = @layouts[name.to_sym]
          raise MissingLayout, "No layout named '#{name}'"
        end

        layout
      end

      def load
        load_layouts
        load_partials
        load_path_info
      end

      def load_layouts
        @layouts = {}
        return unless File.exist?(layouts_path)

        @layouts = layouts_path.children.each_with_object({}) { |file, layouts|
          next if file.basename.to_s.start_with?(".")
          layout = load_view_of_type_at_path(Layout, file)
          layouts[layout.name] = layout
        }
      end

      def load_partials
        @partials = {}
        return unless File.exist?(partials_path)

        @partials = partials_path.children.each_with_object({}) { |file, partials|
          next if file.basename.to_s.start_with?(".")
          partial = load_view_of_type_at_path(Partial, file)
          partials[partial.name] = partial
        }
      end

      def load_path_info
        @info = {}

        Pathname.glob(File.join(templates_path, "**/*")) do |path|
          # TODO: better way to skip this?
          next if path.basename.to_s.start_with?("_")
          next if path.basename.to_s.start_with?(".")

          begin
            if page = page_at_path(path)
              @info[normalize_path(path, templates_path)] = {
                page: page,
                template: layout_with_name(page.info(:template)),
                partials: @partials.merge(partials_at_path(path))
              }
            end
          rescue FrontMatterParsingError => e
            message = "Could not parse front matter for #{path}:\n\n#{e.context}"

            if e.wrapped_exception
              message << "\n#{e.wrapped_exception.problem} at line #{e.wrapped_exception.line} column #{e.wrapped_exception.column}"
            end

            raise FrontMatterParsingError.new(message)
          end
        end
      end

      def page_at_path(path)
        if File.directory?(path)
          if Dir.glob(File.join(path, "index.*")).empty?
            index_page_at_path(path)
          end
        else
          load_view_of_type_at_path(Page, path)
        end
      end

      def index_page_at_path(path)
        # TODO: don't ascend above store path
        path.ascend do |parent_path|
          next unless info = info(normalize_path(parent_path))
          next unless page = info[:page]
          return page
        end
      end

      # TODO: do we always need to make it relative, etc here?
      # maybe break up these responsibilities to the bare minimum required
      def normalize_path(path, relative_from = @path)
        # make it relative
        path = path.relative_path_from(relative_from)
        # we can short-circuit here
        return "/" if path.to_s == "."

        # remove the extension
        path = path.sub_ext("")

        # remove index from the end
        path = path.sub("index", "")

        # actually normalize it
        String.normalize_path(path.to_s)
      end

      def partials_at_path(path)
        # FIXME: don't ascend above store path
        path.ascend.select(&:directory?).each_with_object({}) { |parent_path, partials|
          parent_path.children.select { |child|
            child.basename.to_s.start_with?("_")
          }.each_with_object(partials) { |child, child_partials|
            partial = load_view_of_type_at_path(Partial, child)
            child_partials[partial.name] ||= partial
          }
        }
      end

      def load_view_of_type_at_path(type, path)
        if @processor
          type.load(path, content: @processor.process(path))
        else
          type.load(path)
        end
      end
    end
  end
end
