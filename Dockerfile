ARG RUBY_VERSION=3.3.6
FROM ruby:$RUBY_VERSION-slim AS base

# Rack app lives here
WORKDIR /app

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential

# Install application gems
COPY Gemfile* .
RUN bundle install


# Final stage for app image
FROM base

# Create tmp directory with proper ownership first
RUN mkdir -p /app/tmp && \
    chmod 777 /app/tmp

# Run and own the application files as a non-root user for security
RUN useradd ruby --home /app --shell /bin/bash
USER ruby:ruby

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=ruby:ruby /app /app

# Copy application code
COPY --chown=ruby:ruby . .

# Start the server
EXPOSE 8080
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "8080"]