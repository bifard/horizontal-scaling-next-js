FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps

RUN apk add --no-cache libc6-compat && apk add git
RUN apk add --update iputils-ping

WORKDIR /app

# Копируем package.json из app/ (относительно build context)
COPY app/package.json app/package-lock.json ./

RUN npm cache clean --force
RUN npm install --force
RUN npm install --force --include=dev

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
# Копируем все файлы приложения из app/
COPY app/ .

ARG GH_SHA
ENV GH_SHA=${GH_SHA}
RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app



RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs


COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next


# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static


USER nextjs

EXPOSE 3001
ENV PORT=3001

# server.js is created by next build from the standalone output
# https://nextjs.org/docs/pages/api-reference/next-config-js/output
CMD ["sh", "-c", "HOSTNAME=\"0.0.0.0\" node server.js"]