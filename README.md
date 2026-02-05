# Yabeda::Httpx

[![Gem Version](https://badge.fury.io/rb/yabeda-httpx.svg)](https://badge.fury.io/rb/yabeda-httpx)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

A [Yabeda](https://github.com/yabeda-rb/yabeda) plugin for monitoring [HTTPX](https://gitlab.com/os85/httpx) HTTP client requests. This gem provides automatic instrumentation for external HTTP calls made with HTTPX, exposing metrics for request counts, response times, and errors.

## Why Use This Gem?

HTTPX is a modern, feature-rich HTTP client for Ruby. When making external API calls, it's crucial to monitor:

- **Request latency**: Track how long external services take to respond
- **Error rates**: Detect issues with external dependencies
- **Request volume**: Understand traffic patterns to external services
- **Status code distribution**: Monitor success vs. failure rates

This gem integrates seamlessly with Yabeda's ecosystem to provide these insights with minimal configuration.

## Requirements

- Ruby 2.7 or higher
- [HTTPX](https://gitlab.com/os85/httpx) >= 1.2.0 (for callbacks plugin support)
- [Yabeda](https://github.com/yabeda-rb/yabeda) >= 0.6

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yabeda-httpx'
gem 'yabeda-prometheus' # or another exporter
```

And then execute:

```bash
$ bundle install
```

## Usage

### Basic Usage

```ruby
require 'yabeda/httpx'

# Create an HTTPX session and instrument it
http = HTTPX.plugin(:persistent)
http = Yabeda::Httpx.instrument(http)

# Make requests as normal - metrics are automatically collected
response = http.get("https://api.example.com/users")
response = http.post("https://api.example.com/orders", json: { item: "widget" })
```

### With Rails

In a Rails application, you might create an instrumented client in an initializer or service:

```ruby
# config/initializers/http_client.rb
require 'yabeda/httpx'

module HttpClient
  def self.session
    @session ||= Yabeda::Httpx.instrument(
      HTTPX.plugin(:persistent, :follow_redirects).with(
        timeout: { read_timeout: 30 }
      )
    )
  end
end
```

Then use it in your application:

```ruby
# In a service or controller
response = HttpClient.session.get("https://api.stripe.com/v1/charges")
```

### With Additional HTTPX Plugins

The instrumentation works with any HTTPX plugins:

```ruby
http = HTTPX
  .plugin(:persistent)
  .plugin(:proxy)
  .plugin(:follow_redirects)
  .with(timeout: { read_timeout: 60 })

http = Yabeda::Httpx.instrument(http)
```

## Exposed Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `httpx_requests_total` | counter | `host`, `method` | Total number of HTTP requests initiated |
| `httpx_responses_total` | counter | `host`, `method`, `status` | Total number of HTTP responses received |
| `httpx_errors_total` | counter | `host`, `method`, `error_class` | Total number of request errors (connection failures, timeouts, etc.) |
| `httpx_request_duration` | histogram | `host`, `method`, `status` | Request duration in seconds |

### Histogram Buckets

The request duration histogram uses the following buckets (in seconds):

```
0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, 30, 60, 90
```

This covers a range from 10ms to 90 seconds, suitable for most external API calls.

## Example Prometheus Queries

### Request Rate by Host

```promql
sum(rate(httpx_requests_total[5m])) by (host)
```

### Error Rate

```promql
sum(rate(httpx_errors_total[5m])) / sum(rate(httpx_requests_total[5m])) * 100
```

### p95 Latency

```promql
histogram_quantile(0.95, sum(rate(httpx_request_duration_bucket[5m])) by (le))
```

### Requests by Status Code

```promql
sum(rate(httpx_responses_total[5m])) by (status)
```

## Grafana Dashboard

A sample Grafana dashboard JSON is available in the repository. Import it to visualize:

- Total requests and request rate
- Error rate percentage
- Latency percentiles (p50, p90, p99)
- Requests breakdown by host and HTTP method
- Error tracking by host and error class

## Configuration

The gem automatically configures metrics when required. No additional configuration is needed.

If you need custom bucket sizes, you can override the `BUCKETS` constant before requiring the gem:

```ruby
Yabeda::Httpx::BUCKETS = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5].freeze
require 'yabeda/httpx'
```

## How It Works

The gem uses HTTPX's `:callbacks` plugin (introduced in v1.2.0) to hook into the request lifecycle:

1. **`on_request_started`**: Records the start time and increments the request counter
2. **`on_response_completed`**: Calculates duration and records response metrics
3. **`on_request_error`**: Captures connection errors, timeouts, and other failures

This approach has minimal overhead and doesn't interfere with HTTPX's normal operation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jondavidschober/yabeda-httpx.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Created by [Jon David Schober](https://github.com/jondavidschober) at [Datavine](https://getdatanamic.com).

## See Also

- [Yabeda](https://github.com/yabeda-rb/yabeda) - Extensible framework for collecting metrics
- [HTTPX](https://gitlab.com/os85/httpx) - A Ruby HTTP library for tomorrow... and beyond!
- [yabeda-prometheus](https://github.com/yabeda-rb/yabeda-prometheus) - Prometheus exporter for Yabeda
- [yabeda-http_requests](https://github.com/yabeda-rb/yabeda-http_requests) - Similar gem for Net::HTTP
