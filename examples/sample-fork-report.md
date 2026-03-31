# Fork Report: my-webapp

**Source:** /home/user/my-webapp
**Target:** /home/user/opensource-staging/my-webapp
**Date:** YYYY-MM-DD

## Files Removed
- `.env` (contained 8 secrets)
- `.env.production` (contained 5 secrets)
- `credentials.json` (Google OAuth service account)
- `deploy/ssl/server.key` (private key)

## Secrets Extracted -> .env.example
- `DATABASE_URL` (was hardcoded in docker-compose.yml)
- `REDIS_URL` (was hardcoded in docker-compose.yml)
- `JWT_SECRET` (was in src/config.ts)
- `GOOGLE_CLIENT_ID` (was in src/auth/google.ts)
- `GOOGLE_CLIENT_SECRET` (was in src/auth/google.ts)
- `SMTP_PASSWORD` (was in src/email/transport.ts)
- `STRIPE_SECRET_KEY` (was in src/billing/stripe.ts)
- `SENTRY_DSN` (was in src/monitoring/sentry.ts)

## Internal References Replaced
- `app.mycompany.internal` -> `your-domain.com` (12 occurrences in 6 files)
- `/home/deploy/my-webapp` -> `/home/user/my-webapp` (8 occurrences in 4 files)
- `192.168.1.50` -> `your-server-ip` (3 occurrences in 2 files)
- `mycompany-net` -> `app-network` (2 occurrences in docker-compose.yml)

## Warnings
- [ ] docker-compose.yml had internal network references — replaced with generic names
- [ ] nginx.conf had SSL cert paths — replaced with placeholders
- [ ] CLAUDE.md referenced internal scripts — packager should regenerate

## Next Step
Run opensource-sanitizer to verify sanitization is complete.
