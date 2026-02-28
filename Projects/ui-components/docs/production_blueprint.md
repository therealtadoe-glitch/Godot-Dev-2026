# Production Blueprint - Wallace Commercial Landscaping Ops System

## Scope Covered

- Authentication + role permissions
- Time tracking
- Work tickets + photos
- Equipment inventory + checkout logs
- Repair ticket workflow
- Supabase schema + RLS + storage
- Godot architecture + implementation starter scripts

## Role Permissions Matrix

| Capability | Admin | Crew Lead | Employee | Mechanic |
|---|---|---|---|---|
| Manage users/roles | ✅ | ❌ | ❌ | ❌ |
| Create work tickets | ✅ | ✅ | ❌ | ❌ |
| Update work ticket status | ✅ | ✅ | ❌ | ✅ |
| Submit repair ticket | ✅ | ✅ | ✅ | ✅ |
| Resolve repair ticket | ✅ | ❌ | ❌ | ✅ |
| Manage equipment inventory | ✅ | ✅ (checkout) | ❌ | ✅ |
| View all time entries | ✅ | ✅ | ❌ | ❌ |
| Manage villages/job sites | ✅ | ❌ | ❌ | ❌ |

## State Transitions

### Work tickets
- `TODO -> IN_PROGRESS -> COMPLETE`
- enforced by UI workflow and server-side role update policies

### Repair tickets
- `OPEN -> DIAGNOSING -> WAITING_PARTS -> IN_REPAIR -> RESOLVED -> CLOSED`

## Recommended Operational Rules

- Employees can only have one open time entry at once.
- Equipment item must have `current_holder_user_id = null` before check-out.
- Require photo upload for repair tickets marked as `DAMAGED`.
- Require completion notes for `COMPLETE` tickets.

## Indexing Strategy (for growth)

- `work_tickets(status, created_at desc)`
- `work_ticket_assignments(employee_id, assigned_at desc)`
- `repair_tickets(status, created_at desc)`
- `equipment_items(category, condition_status)`
- `time_entries(user_id, clock_in_at desc)`

## Reporting Extensions (Phase 6+)

- Daily labor hours by village and work type
- Ticket throughput by crew and by lead
- Mean time to repair by equipment category
- Equipment utilization and downtime reports

