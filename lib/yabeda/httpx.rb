# frozen_string_literal: true

require "yabeda"
require "yabeda/httpx/version"

module Yabeda
  module Httpx
    BUCKETS = [0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 30, 60, 90].freeze

    class << self
      # Instruments an HTTPX session with Yabeda metrics using the callbacks plugin.
      #
      # @param session [HTTPX::Session] The HTTPX session to instrument
      # @return [HTTPX::Session] The instrumented session with callbacks attached
      #
      # @example
      #   http = HTTPX.plugin(:persistent)
      #   http = Yabeda::Httpx.instrument(http)
      #   response = http.get("https://example.com")
      #
      def instrument(session)
        session
          .plugin(:callbacks)
          .on_request_started do |request|
            request.instance_variable_set(:@yabeda_start_time, Process.clock_gettime(Process::CLOCK_MONOTONIC))

            Yabeda.httpx.requests_total.increment(
              host: request.uri.host,
              method: request.verb.to_s.upcase
            )
          end
          .on_response_completed do |request, response|
            start_time = request.instance_variable_get(:@yabeda_start_time)
            duration = start_time ? Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time : 0

            tags = {
              host: request.uri.host,
              method: request.verb.to_s.upcase,
              status: response.status.to_s
            }

            Yabeda.httpx.responses_total.increment(tags)
            Yabeda.httpx.request_duration.measure(tags, duration)
          end
          .on_request_error do |request, error|
            Yabeda.httpx.errors_total.increment(
              host: request.uri.host,
              method: request.verb.to_s.upcase,
              error_class: error.class.name
            )
          end
      end
    end

    Yabeda.configure do
      group :httpx do
        counter :requests_total,
                comment: "Total number of HTTPX requests",
                tags: %i[host method]

        counter :responses_total,
                comment: "Total number of HTTPX responses",
                tags: %i[host method status]

        counter :errors_total,
                comment: "Total number of HTTPX request errors",
                tags: %i[host method error_class]

        histogram :request_duration,
                  comment: "HTTPX request duration in seconds",
                  unit: :seconds,
                  tags: %i[host method status],
                  buckets: BUCKETS
      end
    end
  end
end
