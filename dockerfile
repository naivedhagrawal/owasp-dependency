# Use the official OWASP Dependency-Check image
FROM owasp/dependency-check:latest

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set environment variables
ENV SCAN_PATH=/app

# Set working directory
WORKDIR ${SCAN_PATH}

# Update NVD data during build
RUN dependency-check --updateonly --nvdApiKey ${NVD_API_KEY}

# Default command to scan the working directory
CMD ["--scan", "/app", "--nvdApiKey", "${NVD_API_KEY}"]
