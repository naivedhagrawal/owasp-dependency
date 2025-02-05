FROM openjdk:11-jre-slim-buster

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set environment variables
ENV SCAN_PATH=/app \
    NVD_DATA_PATH=/opt/dependency-check/data

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install latest Dependency-Check
WORKDIR /tmp
RUN wget https://github.com/jeremylong/DependencyCheck/releases/latest/download/dependency-check-latest-release.zip && \
    unzip dependency-check-latest-release.zip -d /opt && \
    rm dependency-check-latest-release.zip

# Create symlink for convenience
RUN ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check

# Update NVD data during build
RUN /usr/local/bin/dependency-check --updateonly --nvdApiKey ${NVD_API_KEY} && \
    rm -rf /opt/dependency-check/data/.lock

# Set working directory
WORKDIR ${SCAN_PATH}

# Set entrypoint to Dependency-Check script
ENTRYPOINT ["/usr/local/bin/dependency-check"]

# Default command to scan the working directory
CMD ["--scan", "${SCAN_PATH}", "--nvdApiKey", "${NVD_API_KEY}"]