require "magellan/build"

module Magellan
  module Build
    class Git < Base

      desc "guard_clean", "Raise error if some difference exists."
      def guard_clean
        clean? && committed? or raise("There are files that need to be committed first.")
      end

      desc "push", "push commit and tag it"
      def push
        tag_version { git_push } unless already_tagged?
      end

      no_commands do

        def clean?
          sh_with_code("git diff --exit-code")[1] == 0
        end

        def committed?
          sh_with_code("git diff-index --quiet --cached HEAD")[1] == 0
        end

        def tag_version
          version_tag = version = VersionFile.current
          sh "git tag -a -m \"Version #{version}\" #{version_tag}"
          $stdout.puts "Tagged #{version_tag}."
          yield if block_given?
        rescue
          $stderr.puts "Untagging #{version_tag} due to error."
          sh_with_code "git tag -d #{version_tag}"
          raise
        end

        def git_push
          perform_git_push
          perform_git_push ' --tags'
          $stdout.puts "Pushed git commits and tags."
        end

        def perform_git_push(options = '')
          cmd = "git push #{options}"
          out, code = sh_with_code(cmd)
          raise "Couldn't git push. `#{cmd}' failed with the following output:\n\n#{out}\n" unless code == 0
        end

        def already_tagged?
          if sh('git tag').split(/\n/).include?(version_tag)
            $stderr.puts "Tag #{version_tag} has already been created."
            true
          end
        end

      end

    end
  end
end
