# Base stage
FROM node:20 AS base
WORKDIR /app
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build stage (canary/stable/beta)
FROM base AS build

ARG VERSION=stable
ENV APP_VERSION=$VERSION

RUN echo "Building $VERSION version"
RUN if [ "$VERSION" = "canary" ]; then \
      npm run build:canary; \
    elif [ "$VERSION" = "beta" ]; then \
      npm run build:beta; \
    else \
      npm run build; \
    fi

# Final stage
FROM node:20-slim AS final
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY package*.json ./
RUN npm install --omit=dev

ENV NODE_ENV=production
CMD ["node", "dist/index.js"]
