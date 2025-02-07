FROM owasp/dependency-check:latest

# Set environment variables
ENV NVD_API_KEY="NVD_API_KEY"

# Update the NVD database
RUN /usr/share/dependency-check/bin/dependency-check.sh --updateonly --nvdApiKey ${NVD_API_KEY}

# Set working directory
WORKDIR /src

# Define volumes
VOLUME ["/src", "/report"]

# Set user
USER 1000

# Default command
CMD ["--help"]

# Entry point
ENTRYPOINT ["/usr/share/dependency-check/bin/dependency-check.sh"]
