# Use the official OWASP Dependency-Check image
FROM owasp/dependency-check:latest

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set environment variables
ENV SCAN_PATH=/app \
    NVD_DATA_PATH=/usr/share/dependency-check/data

# Set working directory
WORKDIR ${SCAN_PATH}

# Update NVD data during build
RUN dependency-check.sh --updateonly --nvdApiKey ${NVD_API_KEY} && \
    rm -rf ${NVD_DATA_PATH}/.lock

# Set entrypoint to Dependency-Check script
ENTRYPOINT ["dependency-check.sh"]

# Default command to scan the working directory
CMD ["--scan", "${SCAN_PATH}", "--nvdApiKey", "${NVD_API_KEY}"]

# Instructions for the user (optional but helpful)
# Build the Docker image:
# docker build --build-arg NVD_API_KEY=<your-key> -t dependency-check:latest .
# Run the container:
# docker run -v $(pwd):/app -e NVD_API_KEY=<your-key> dependency-check:latest
