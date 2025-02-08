# Use a lightweight Node.js image as the builder stage
FROM node:16.17.0-alpine as builder
# Set the working directory inside the container
WORKDIR /app
# Copy dependency files first to take advantage of Docker's caching mechanism
COPY ./package.json ./yarn.lock .
# Install project dependencies
RUN yarn install
# Copy the rest of the application files
COPY . .
# Define build-time argument for the API key
ARG TMDB_V3_API_KEY
# Set environment variables for the frontend
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL=${VITE_APP_API_ENDPOINT_URL}
# Build the application for production
RUN yarn build
# Use a minimal Alpine Linux image as the final stage
FROM alpine:latest
# Install Nginx web server manually
RUN apk add --no-cache nginx
# Set the working directory to the default Nginx serving directory
WORKDIR /usr/share/nginx/html
# Remove any default Nginx HTML files
RUN rm -rf ./*
# Copy the built application from the builder stage
COPY --from=builder /app/dist .
# Copy a custom Nginx configuration file (if needed)
COPY nginx.conf /etc/nginx/nginx.conf
# Expose port 80 for incoming HTTP traffic
EXPOSE 80
# Start Nginx in the foreground to keep the container running
CMD ["nginx", "-g", "daemon off;"]