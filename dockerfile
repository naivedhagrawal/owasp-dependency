# Use the official OWASP Dependency-Check image
FROM owasp/dependency-check:latest

USER root

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set environment variables
ENV SCAN_PATH=/src \
    REPORT_PATH=/report \
    USERNAME=dependencycheck

# Set working directory
WORKDIR ${SCAN_PATH}

# Define volumes for source code and reports
VOLUME ["/src", "/report"]

# Install `shadow` package to get `adduser` (Alpine-based image)
RUN apk add --no-cache shadow

# Create a non-root user with `adduser`
RUN adduser -D -s /bin/sh ${USERNAME} && \
    chown -R ${USERNAME}:${USERNAME} /usr/share/dependency-check /src /report

# Switch to non-root user
USER ${USERNAME}

# Update NVD data as the new user
RUN /usr/share/dependency-check/bin/dependency-check.sh --updateonly --nvdApiKey ${NVD_API_KEY}

# Set ENTRYPOINT to always run dependency-check.sh
ENTRYPOINT ["/usr/share/dependency-check/bin/dependency-check.sh"]

# Default CMD for scanning
CMD ["--scan", "/src", "--out", "/report", "--nvdApiKey", "${NVD_API_KEY}"]
