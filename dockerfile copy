# Use OpenJDK 11 slim as the base image
FROM openjdk:11-jre-slim

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set environment variables
ENV DEPENDENCY_CHECK_VERSION=12.0.1 \
    SCAN_PATH=/app \
    NVD_DATA_PATH=/opt/dependency-check/data

# Install dependencies and Dependency-Check
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip curl && \
    wget https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK_VERSION}/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
    unzip dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip -d /opt && \
    ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check && \
    rm dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Update NVD data during build
RUN /usr/local/bin/dependency-check --updateonly --nvdApiKey ${NVD_API_KEY} && \
    rm -rf /opt/dependency-check/data/.lock

# Set working directory
WORKDIR ${SCAN_PATH}

# Set entrypoint to Dependency-Check script
ENTRYPOINT ["/usr/local/bin/dependency-check"]

# Default command to scan the working directory
CMD ["--scan", "${SCAN_PATH}", "--nvdApiKey", "${NVD_API_KEY}"]

# Instructions for the user (optional but helpful)
# Build the Docker image:
# docker build --build-arg NVD_API_KEY=<your-key> -t dependency-check:12.0.1 .
# Run the container:
# docker run -v $(pwd):/app -e NVD_API_KEY=<your-key> dependency-check:12.0.1
