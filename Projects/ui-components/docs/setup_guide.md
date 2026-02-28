# Setup Guide (Supabase + Godot 4.6)

## A. Supabase Project Setup

1. Create a Supabase project.
2. In **Project Settings -> API**, copy:
   - Project URL
   - anon public key
3. In **SQL Editor**, run `docs/supabase_schema.sql`.
4. In **Authentication -> Providers**, enable Email provider.
5. In **Authentication -> URL Configuration**, set production and local redirect URLs.
6. In **Storage**, verify buckets exist:
   - `work-ticket-photos`
   - `repair-photos`

## B. Godot Project Setup

1. Open `Projects/ui-components/project.godot` in Godot 4.6.
2. Add autoload singletons:
   - `res://src/autoload/app_state.gd` as `AppState`
   - `res://src/services/supabase_client.gd` as `SupabaseClient`
   - `res://src/services/auth_service.gd` as `AuthService`
3. Configure environment values in `res://src/core/app_config.gd`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
4. Ensure Supabase addon is enabled (already installed per your note).
5. Set startup scene to your login/dashboard container.

## C. Initial Admin Bootstrap

1. Create first user via Supabase Auth dashboard.
2. Insert a matching `profiles` row with role `ADMIN`.
3. Sign in from Godot app to validate RLS behavior.

## D. Suggested Implementation Phases

1. **Phase 1**: Auth + Profiles + Role UI guards.
2. **Phase 2**: Time tracking + village/job site selector.
3. **Phase 3**: Work tickets + assignment + photos.
4. **Phase 4**: Equipment inventory and checkout logs.
5. **Phase 5**: Repair tickets + mechanic queue + reporting.

