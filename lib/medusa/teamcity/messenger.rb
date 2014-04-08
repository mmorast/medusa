begin
  require 'teamcity/runner_common'
  require 'teamcity/utils/service_message_factory'
rescue LoadError
end

if defined?(::Rake::TeamCity::RunnerCommon)
  module Medusa
    module Teamcity
      class Messenger
        include ::Rake::TeamCity::RunnerCommon

        def notify_example_group_started(file, group_name)
          logger.debug(::Rake::TeamCity::MessageFactory.create_suite_started(group_name, file))
          require 'pry'; binding.pry
          send_msg(::Rake::TeamCity::MessageFactory.create_suite_started(group_name, file))
        end

        def notify_example_group_finished(file, group_name)
          logger.debug(::Rake::TeamCity::MessageFactory.create_suite_finished(group_name))
          send_msg(::Rake::TeamCity::MessageFactory.create_suite_finished(group_name))
        end

        def notify_example_group_summary(summary)
          # send_msg(summary)
        end

        def notify_example_started(file, example_name)
          logger.debug(::Rake::TeamCity::MessageFactory.create_test_started(example_name, file))
          send_msg(::Rake::TeamCity::MessageFactory.create_test_started(example_name, file))
        end

        def notify_example_finished(file, result)
          if result.failure? || result.fatal?
            notify_failure(file, result)
          elsif result.pending?
            notify_pending(file, result)
          end

          duration = result.duration || 0 # sometimes rspec doesn't set a duration in its results
          logger.debug(::Rake::TeamCity::MessageFactory.create_test_finished(result.description, duration, nil))
          send_msg(::Rake::TeamCity::MessageFactory.create_test_finished(result.description, duration, nil))
        end

        private

        def logger
          @logger ||= Logger.new('team_city.log')
        end

        def notify_failure(file, result)
          logger.debug(::Rake::TeamCity::MessageFactory.create_test_failed(result.description, result.exception, result.exception_backtrace.join("\n")))
          send_msg(::Rake::TeamCity::MessageFactory.create_test_failed(result.description, result.exception, result.exception_backtrace.join("\n")))
        end

        def notify_pending(file, result)
          logger.debug(::Rake::TeamCity::MessageFactory.create_test_ignored(result.description, ''))
          send_msg(::Rake::TeamCity::MessageFactory.create_test_ignored(result.description, ''))
        end
      end
    end
  end
end

