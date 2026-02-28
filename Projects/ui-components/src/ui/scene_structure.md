# Suggested Scene Structure

- `Main.tscn`
  - `AuthGate` (switches login/dashboard)
  - `GlobalToasts`

- `auth/LoginView.tscn`
  - Email/Password fields
  - Sign in button

- `dashboard/DashboardView.tscn`
  - Header (user + role)
  - TabContainer
    - Time Tracking Tab
    - Work Tickets Tab
    - Equipment Tab
    - Repairs Tab
    - Admin Tab (role guarded)

- `time/TimeTrackingView.tscn`
  - Village dropdown
  - Job Site dropdown
  - Clock in / out button
  - Day hours summary list

- `tickets/TicketBoardView.tscn`
  - Status columns (TODO, IN_PROGRESS, COMPLETE)
  - Ticket details panel
  - Photo uploader

- `equipment/EquipmentInventoryView.tscn`
  - Category filters
  - Inventory table
  - Check-out/in modal

- `repairs/RepairQueueView.tscn`
  - Open/active/resolved filters
  - Ticket form and mechanic updates

