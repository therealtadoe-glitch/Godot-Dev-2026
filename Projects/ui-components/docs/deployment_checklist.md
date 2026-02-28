# Deployment Checklist

## Infrastructure

- [ ] Supabase project has production region selected.
- [ ] SQL schema + RLS deployed from migration pipeline.
- [ ] Storage buckets created and private.
- [ ] Backup strategy enabled for Postgres.

## Security

- [ ] No service_role key in client code.
- [ ] Anon key loaded from environment or secure config.
- [ ] JWT refresh flow tested.
- [ ] RLS policy tests pass for each role.
- [ ] Audit logs enabled for sensitive tables (optional via trigger).

## Application Quality

- [ ] Role-based navigation tested (Admin, Crew Lead, Employee, Mechanic).
- [ ] Clock in/out edge cases handled (double clock-in, missing clock-out).
- [ ] Ticket lifecycle transitions validated.
- [ ] Equipment checkout/check-in conflict prevention tested.
- [ ] Repair workflow tested end-to-end with photos.

## Operations

- [ ] Error telemetry configured (Sentry or equivalent).
- [ ] Daily health check for API response and auth refresh.
- [ ] Onboarding runbook created for new crews/users.
- [ ] Data retention policy documented.

