# Use the official OWASP Dependency-Check image
FROM owasp/dependency-check:latest

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Switch to the existing non-root user `dependencycheck`
USER ${USERNAME}

# Update NVD data as the new user
RUN /usr/share/dependency-check/bin/dependency-check.sh --updateonly --nvdApiKey ${NVD_API_KEY}

# Set ENTRYPOINT to always run dependency-check.sh
ENTRYPOINT ["/usr/share/dependency-check/bin/dependency-check.sh"]

# Default CMD for scanning
CMD ["--scan", "/src", "--out", "/report", "--nvdApiKey", "${NVD_API_KEY}"]