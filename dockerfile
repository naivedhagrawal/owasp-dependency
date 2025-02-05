# Use OWASP Dependency-Check as the base image
FROM owasp/dependency-check:latest

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set environment variables
ENV SCAN_PATH=/app \
    NVD_DATA_PATH=/opt/dependency-check/data

# Update NVD data during build (optional)
RUN dependency-check --updateonly --nvdApiKey ${NVD_API_KEY} && \
    rm -rf /opt/dependency-check/data/.lock

# Set working directory
WORKDIR ${SCAN_PATH}

# Set entrypoint to Dependency-Check script
ENTRYPOINT ["dependency-check"]

# Default command to scan the working directory
CMD ["--scan", "${SCAN_PATH}", "--nvdApiKey", "${NVD_API_KEY}"]

# Instructions for the user (optional but helpful)
# Build the Docker image:
# docker build --build-arg NVD_API_KEY=<your-key> -t dependency-check .
# Run the container:
# docker run -v $(pwd):/app -e NVD_API_KEY=<your-key> dependency-check
