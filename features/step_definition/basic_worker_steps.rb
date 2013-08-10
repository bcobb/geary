require 'geary/cli'
require 'aruba'
require 'childprocess'
require 'shellwords'
require 'timeout'

When(/^geary runs with the flags "(.*?)"$/) do |flags|
  @geary_processes ||= []

  in_current_dir do
    process = ChildProcess.build(*Shellwords.shellwords(detect_ruby("geary #{flags}")))
    process.io.inherit!

    @geary_processes << process

    process.start
  end
end

Then /^the file "([^"]*)" should eventually contain:$/ do |file, partial_content|
  regexp = regexp(partial_content)
  prep_for_fs_check do 
    begin
      Timeout.timeout(exit_timeout) do
        loop do
          if File.exists?(file)
            content = IO.read(file)
            break if content =~ regexp
          end

          sleep 0.1
        end
      end
    rescue Timeout::Error
      if File.exists?(file)
        fail "File '#{file}' did not contain '#{partial_content}'"
      else
        fail "File '#{file}' does not exist"
      end
    end
  end
end

After do
  @geary_processes.each(&:stop)
end
