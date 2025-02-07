# Use the official OWASP Dependency-Check image
FROM owasp/dependency-check:latest

# Declare build argument for NVD API key
ARG NVD_API_KEY

# Set the environment variable for runtime use
ENV NVD_API_KEY=${NVD_API_KEY}

# Run NVD database update before scanning
CMD ["/bin/sh", "-c", "/usr/share/dependency-check/bin/dependency-check.sh --updateonly --nvdApiKey $NVD_API_KEY && exec /usr/share/dependency-check/bin/dependency-check.sh --scan /src --out /report --nvdApiKey $NVD_API_KEY"]
