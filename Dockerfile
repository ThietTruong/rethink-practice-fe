# Stage 1: Build the Next.js application
# We use a specific Node.js version to build the project.
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and lock file
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Next.js application for production
RUN npm run build

# ---

# Stage 2: Create the production image
# Use a lightweight Node.js image for the final production server.
FROM node:20-alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and lock file from the builder stage
COPY --from=builder /usr/src/app/package*.json ./

# Install only production dependencies to keep the image small
RUN npm install --production

# Copy the build output from the builder stage
# This includes the '.next' directory which contains the optimized server and static assets.
COPY --from=builder /usr/src/app/.next ./.next

# Copy the public directory
COPY --from=builder /usr/src/app/public ./public

# Expose port 3000, the default port for Next.js
EXPOSE 3000

# The command to start the optimized Next.js server
CMD ["npm", "start"]
