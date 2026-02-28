# Wallace Commercial Landscaping - System Architecture (Godot 4.6 + Supabase)

## 1) High-Level Architecture

- **Client**: Godot 4.6 desktop/mobile app.
- **Backend**: Supabase (Postgres, Auth, Storage, PostgREST).
- **Integration style**: Thin Godot service layer over Supabase REST APIs.
- **Auth model**: JWT (access + refresh token) from Supabase Auth.
- **Authorization model**: Postgres RLS + role checks from `profiles` table.

## 2) Clean Architecture Layout

- `src/autoload/`: singleton state + app bootstrap.
- `src/core/`: constants, utility functions, app config.
- `src/models/`: typed data models (Resource based).
- `src/services/`: integration and domain services.
- `src/controllers/`: orchestration between UI and services.
- `src/ui/`: scene controllers and reusable widgets.

### Selected Pattern

- **MVCS** (Model-View-Controller-Service).
- Controllers emit domain signals to views.
- Services contain all Supabase communication.
- Views do not call Supabase directly.

## 3) Signal Flow (Typical)

1. User action in UI emits intent (e.g., `clock_in_pressed`).
2. Screen controller validates input.
3. Controller calls domain service (e.g., `TimeTrackingService.clock_in`).
4. Service calls `SupabaseClient.request()`.
5. Service parses response to model resources.
6. Controller emits success/failure signal for UI update.

## 4) Scalability Notes

- Use server-side pagination for ticket/equipment tables (`limit`, `offset`, ordering).
- Keep table writes append-friendly (logs and photos tables are immutable records).
- Use indexes on high-volume filters: status, assigned users, created dates.
- Add materialized views for future analytics dashboards (hours/day, completion SLA).
- For multi-crew growth, crew-based filtering should be done server-side via RLS-safe queries.

## 5) Security Model

- Never embed Supabase `service_role` key in Godot app.
- Use anon key only in client; rely on RLS for data protection.
- Restrict updates by role (admin/mechanic/crew lead policies in SQL).
- Storage buckets are private; access via authenticated session only.
- Add periodic token refresh + forced logout on refresh failure.

## 6) Data Flow Summary

- **Auth**: email/password -> `auth/v1/token` -> session in `AppState`.
- **Time**: clock in/out writes to `time_entries` with site context.
- **Work tickets**: create ticket + assignments + photos in storage.
- **Equipment**: update item holder + append checkout log.
- **Repair**: submit ticket + mechanic updates status until resolved.

