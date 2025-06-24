FROM ubuntu:20.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH "$PATH:/flutter/bin"

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Get Flutter packages
RUN flutter pub get

# Build for web
RUN flutter build web

# Expose the port
EXPOSE 80

# Install a simple HTTP server to serve the web build
RUN apt-get install -y python3

# Command to serve the app
CMD ["python3", "-m", "http.server", "80", "--directory", "build/web"]