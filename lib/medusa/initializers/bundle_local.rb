module Medusa
  module Initializers
    class BundleLocal < Abstract
      def run(connection, master, worker)
        result = Result.new("bundle --local --path .bundle")

        status = connection.exec("bundle --local --path .bundle") do |output|
          master.initializer_output(worker, self, output)
          result << output
        end

        result.exit_status = status

        return result
      end
    end
  end
end