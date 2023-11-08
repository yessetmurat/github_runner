# Using specific version for reproducibility
FROM ubuntu:20.04
LABEL org.opencontainers.image.source=https://github.com/yessetmurat/github_runner

ARG RUNNER_VERSION
ARG RUNNER_ARCH

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Installing dependencies and cleanup in a single RUN to reduce image layers
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -s /bin/bash runner

# Use the runner user for the following commands
USER runner
WORKDIR /home/runner

# Download and install the GitHub Actions runner
RUN mkdir -p actions-runner && \
    curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar -xzf actions-runner.tar.gz -C actions-runner && \
    rm actions-runner.tar.gz

# Switch back to root to run the install dependencies script
USER root
RUN actions-runner/bin/installdependencies.sh

# Copy the start script and adjust permissions
COPY ./start.sh start.sh
RUN chown runner:runner start.sh && chmod +x start.sh

# Switch to the runner user for the final image
USER runner

# Using exec format for the entrypoint to ensure signals are properly handled
ENTRYPOINT ["/home/runner/start.sh"]
