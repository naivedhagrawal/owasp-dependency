# Use the latest Eclipse Temurin (OpenJDK) as the base image
FROM eclipse-temurin:latest

# Set environment variables
ENV DEPENDENCY_CHECK_VERSION=12.1.0 \
    SCAN_PATH=/app \
    NVD_DATA_PATH=/opt/dependency-check/data \
    NVD_API_KEY=""

# Install dependencies and Dependency-Check
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip curl && \
    wget https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK_VERSION}/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
    unzip dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip -d /opt && \
    ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check && \
    rm dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Update NVD data during build (with a default or runtime API key)
RUN /usr/local/bin/dependency-check --updateonly --nvdApiKey "$NVD_API_KEY" && \
    rm -rf /opt/dependency-check/data/.lock

# Set working directory
WORKDIR ${SCAN_PATH}

# Set entrypoint to Dependency-Check script
ENTRYPOINT ["/usr/local/bin/dependency-check"]

# Default command to scan the working directory
CMD ["--scan", "${SCAN_PATH}", "--nvdApiKey", "$NVD_API_KEY"]
