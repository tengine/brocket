require "brocket"

require 'yaml'
require 'thor'

module BRocket
  class Docker < Configurable

    desc "config", "show configurations in Dockerfile"
    def config
      $stdout.puts(YAML.dump(config_hash))
    end

    desc "build", "build docker image"
    def build
      info("[docker build] starting")
      c = config_hash
      Dir.chdir(working_dir) do
        begin
          execute(c['BEFORE_BUILD'])
          cmd = build_build_command
          execute(cmd)
          execute(c['ON_BUILD_COMPLETE'])
        rescue
          execute(c['ON_BUILD_ERROR'])
          raise
        ensure
          execute(c['AFTER_BUILD'])
        end
      end
      success("[docker build] OK")
    end

    desc "push", "push docker image to docker hub"
    def push
      info("[docker push] starting")
      cmd = build_push_command
      sh(cmd)
      success("[docker push] OK")
    end

    desc "call_before_build", "call BEFORE_BUILD callback manually"
    def call_before_build
      execute(config_hash['BEFORE_BUILD'])
    end

    desc "call_after_build", "call AFTER_BUILD callback manually"
    def call_after_build
      execute(config_hash['AFTER_BUILD'])
    end

    no_commands do
      def build_build_command
        img_name = config_image_name
        version = sub(VersionFile).current
        cmd = "docker build -t #{img_name}:#{version}"
        if options[:dockerfile]
          fp = config_relpath
          unless fp == "Dockerfile"
            cmd << ' -f ' << config_relpath
          end
        end
        cmd << ' .'
        return cmd
      end

      def build_push_command
        img_name = [
          config_hash['DOCKER_PUSH_REGISTRY'],
          config_hash['DOCKER_PUSH_USERNAME'],
          config_image_name
        ].compact.join('/')
        version = sub(VersionFile).current
        build_cmd = config_hash['DOCKER_PUSH_COMMAND'] || 'docker push'
        return "#{build_cmd} #{img_name}:#{version}"
      end

      def execute(commands)
        return unless commands
        commands = commands.is_a?(Array) ? commands : [commands]
        commands = commands.compact.map(&:strip).reject(&:empty?)
        commands.each{|cmd| sh(cmd) }
      end
    end

  end
end
