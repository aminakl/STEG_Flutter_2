# STEG LOTO Application - Workflow Documentation

This document provides a comprehensive overview of the workflow processes implemented in the STEG LOTO application, including the multi-stage validation process, consignation workflow, and notification system.

## Login Credentials

All users in the system have the password: `admin123`. Use the following credentials to test different roles:

| Role | Matricule | Password | Email |
|------|-----------|----------|-------|
| ADMIN | ADMIN001 | admin123 | admin@steg.com.tn |
| CHEF_EXPLOITATION | CHEF001 | admin123 | chef@steg.com.tn |
| CHEF_DE_BASE | BASE001 | admin123 | base@steg.com.tn |
| CHARGE_EXPLOITATION | CHARGEX001 | admin123 | chargex@steg.com.tn |
| CHARGE_CONSIGNATION | CHARGE001 | admin123 | charge@steg.com.tn |

## Table of Contents
- [User Roles and Permissions](#user-roles-and-permissions)
- [Multi-Stage Validation Process](#multi-stage-validation-process)
- [Consignation Workflow](#consignation-workflow)
- [Deconsignation Workflow](#deconsignation-workflow)
- [Notification System](#notification-system)
- [Admin Dashboard and KPIs](#admin-dashboard-and-kpis)

## User Roles and Permissions

The application implements a comprehensive role-based access control system with the following roles:

### 1. ADMIN
- **Description**: System administrators with full access to all features
- **Permissions**:
  - Create, read, update, and delete all resources
  - Manage users (create, update, delete)
  - Access all dashboards and reports
  - Override any workflow step if necessary

### 2. CHEF_EXPLOITATION
- **Description**: Responsible for creating lockout notes
- **Permissions**:
  - Create new lockout notes
  - Submit notes for validation
  - View notes they have created
  - Update notes in DRAFT status

### 3. CHEF_DE_BASE
- **Description**: Responsible for the first stage of validation
- **Permissions**:
  - View notes in PENDING_CHEF_BASE status
  - Validate or reject notes with detailed reasons
  - View validation history

### 4. CHARGE_EXPLOITATION
- **Description**: Responsible for the second stage of validation and assignment
- **Permissions**:
  - View notes in PENDING_CHARGE_EXPLOITATION status
  - Validate or reject notes
  - Assign validated notes to Chargé de consignation users

### 5. CHARGE_CONSIGNATION
- **Description**: Responsible for performing consignation and deconsignation
- **Permissions**:
  - View notes assigned to them
  - Start and complete consignation processes
  - Start and complete deconsignation processes

## Multi-Stage Validation Process

The application implements a comprehensive multi-stage validation process to ensure that lockout notes are properly reviewed and approved before consignation can begin.

### Stage 1: Note Creation
1. **Actor**: Chef d'exploitation
2. **Actions**:
   - Creates a new lockout note with the following information:
     - Poste HT (High-Tension Post) identifier
     - Equipment details
     - Other relevant information
   - Submits the note for validation
3. **Status Change**: DRAFT → PENDING_CHEF_BASE
4. **System Actions**:
   - Records creation timestamp
   - Associates note with creator
   - Notifies Chef de Base users of pending validation

### Stage 2: First Validation (Chef de Base)
1. **Actor**: Chef de Base
2. **Actions**:
   - Reviews the note details
   - Validates or rejects the note
   - If rejected, provides detailed rejection reason
3. **Status Change**: 
   - If validated: PENDING_CHEF_BASE → PENDING_CHARGE_EXPLOITATION
   - If rejected: PENDING_CHEF_BASE → REJECTED
4. **System Actions**:
   - Records validation timestamp and validator
   - Notifies Chargé d'exploitation users of pending validation or rejection
   - Notifies note creator of the validation result

### Stage 3: Second Validation (Chargé d'exploitation)
1. **Actor**: Chargé d'exploitation
2. **Actions**:
   - Reviews the note details
   - Validates or rejects the note
   - If validated, assigns the note to a Chargé de consignation
3. **Status Change**: 
   - If validated: PENDING_CHARGE_EXPLOITATION → VALIDATED
   - If rejected: PENDING_CHARGE_EXPLOITATION → REJECTED
4. **System Actions**:
   - Records validation timestamp and validator
   - Records assignment timestamp and assignee
   - Notifies assigned Chargé de consignation
   - Notifies note creator of the validation result

## Consignation Workflow

After a note has been validated and assigned, the Chargé de consignation can begin the consignation process.

### Stage 1: Start Consignation
1. **Actor**: Chargé de consignation
2. **Actions**:
   - Views assigned notes
   - Starts the consignation process
3. **System Actions**:
   - Records consignation start timestamp
   - Updates note status in real-time
   - Notifies relevant stakeholders

### Stage 2: Complete Consignation
1. **Actor**: Chargé de consignation
2. **Actions**:
   - Completes all necessary consignation steps
   - Marks the consignation as complete
3. **System Actions**:
   - Records consignation completion timestamp
   - Updates note status in real-time
   - Notifies relevant stakeholders

## Deconsignation Workflow

After work has been completed, the Chargé de consignation can begin the deconsignation process.

### Stage 1: Start Deconsignation
1. **Actor**: Chargé de consignation
2. **Actions**:
   - Views notes with completed consignation
   - Starts the deconsignation process
3. **System Actions**:
   - Records deconsignation start timestamp
   - Updates note status in real-time
   - Notifies relevant stakeholders

### Stage 2: Complete Deconsignation
1. **Actor**: Chargé de consignation
2. **Actions**:
   - Completes all necessary deconsignation steps
   - Marks the deconsignation as complete
3. **System Actions**:
   - Records deconsignation completion timestamp
   - Updates note status in real-time
   - Notifies relevant stakeholders that the process is complete

## Notification System

The application implements a comprehensive in-app notification system to keep users informed about important events and status changes throughout the workflow process.

### Notification Types
1. **In-App Notifications**:
   - Real-time alerts within the application
   - Notification badge with unread count
   - Notification center with read/unread status
   - Ability to mark individual or all notifications as read
   - Clickable notifications that navigate to the relevant note

2. **Email Notifications** (planned for future implementation):
   - Status change alerts
   - Daily summaries

3. **Push Notifications** (planned for future implementation):
   - Critical status changes
   - Assignment notifications
   - Urgent validation requests

### Notification Triggers
The system automatically generates notifications for the following events:

1. **Note Creation**:
   - Notifies all Chef de Base users when a new note is created
   - Message includes the post HT identifier

2. **Validation by Chef de Base**:
   - Notifies the note creator when their note is validated by Chef de Base
   - Notifies all Charge Exploitation users about notes pending their validation

3. **Validation by Charge Exploitation**:
   - Notifies the note creator when their note is fully validated

4. **Note Rejection**:
   - Notifies the note creator when their note is rejected at any stage
   - Includes the rejection reason in the notification

5. **Note Assignment**:
   - Notifies the assigned Charge Consignation user about the new assignment
   - Notifies the note creator that their note has been assigned

6. **Consignation Process**:
   - Notifies relevant stakeholders when consignation starts
   - Notifies relevant stakeholders when consignation completes

7. **Deconsignation Process**:
   - Notifies relevant stakeholders when deconsignation starts
   - Notifies relevant stakeholders when deconsignation completes

## Admin Dashboard and KPIs

The admin dashboard provides a comprehensive overview of the system's performance and key metrics, allowing administrators to monitor workflow efficiency, identify bottlenecks, and make data-driven decisions.

### Dashboard Overview
The admin dashboard is accessible only to users with the ADMIN role and provides real-time statistics and visualizations of the application's performance. The dashboard is divided into several sections:

1. **Summary Statistics**: High-level overview of the system's current state
2. **Performance Metrics**: Detailed analysis of workflow efficiency
3. **User Activity**: Breakdown of user contributions and performance
4. **Monthly Trends**: Historical data showing patterns over time

### Available KPIs

1. **Process Metrics**:
   - **Total Notes**: Count of all notes in the system by status
   - **Recent Activity**: Notes created in the last 30 days
   - **Average Validation Time**: Time from creation to final validation (in hours)
   - **Average Consignation Time**: Duration of the consignation process (in hours)
   - **Average Deconsignation Time**: Duration of the deconsignation process (in hours)
   - **Completion Rate**: Percentage of notes that complete the full workflow

2. **User Activity Metrics**:
   - **Notes Created by User**: Breakdown of note creation by Chef d'exploitation users
   - **Notes Validated by Chef de Base**: Validation statistics for each Chef de Base user
   - **Notes Validated by Charge Exploitation**: Validation statistics for each Charge Exploitation user
   - **Notes Assigned**: Distribution of notes assigned to each Charge Consignation user
   - **User Efficiency**: Average processing time per user role

3. **Status Distribution**:
   - **Notes by Status**: Visual representation of notes in each status category
   - **Notes by Assignment**: Distribution of notes assigned to different users
   - **Monthly Status Trends**: Changes in status distribution over time

4. **Notification Metrics**:
   - **Total Notifications**: Count of all notifications generated
   - **Unread Notifications**: Count of unread notifications in the system
   - **Notification Types**: Distribution of notifications by type

### Reporting Capabilities

1. **Operational Reports**:
   - **Daily Activity Summary**: Overview of actions performed each day
   - **Pending Validations Report**: List of notes awaiting validation by role
   - **Completed Processes Report**: Summary of completed consignation and deconsignation processes
   - **User Workload Report**: Analysis of current workload distribution

2. **Compliance Reports**:
   - **Audit Logs**: Detailed record of all actions performed in the system
   - **User Activity Logs**: Breakdown of actions by user
   - **Process Compliance Metrics**: Analysis of adherence to defined workflows
   - **Time-to-Completion Analysis**: Detailed breakdown of time spent at each workflow stage

### Accessing the Admin Dashboard

1. **Login as Admin**:
   - Matricule: ADMIN001
   - Password: admin123

2. **Navigate to Dashboard**:
   - Click on the "Admin Dashboard" option in the main navigation menu
   - The dashboard will load with real-time data

3. **Interacting with the Dashboard**:
   - Use the date range filters to view data for specific periods
   - Click on chart elements to drill down into detailed information
   - Export reports in various formats (CSV, PDF) for offline analysis

## Testing the Complete Workflow

Follow these steps to test the complete workflow using the provided user accounts:

### 1. Create a Lockout Note
1. **Login as Chef d'exploitation**:
   - Matricule: CHEF001
   - Password: admin123

2. **Create a new lockout note**:
   - Navigate to the "Create Note" page
   - Fill in the Poste HT field (e.g., "POSTE-225kV-01")
   - Add equipment details (e.g., "Transformateur principal, disjoncteur HT")
   - Submit the note

3. **Verify**:
   - The note should appear with status "PENDING_CHEF_BASE"
   - Logout

### 2. First Validation by Chef de Base
1. **Login as Chef de Base**:
   - Matricule: BASE001
   - Password: admin123

2. **Validate the note**:
   - Navigate to the "Pending Notes" page
   - Find the note created in step 1
   - Review the details
   - Click "Validate" (or "Reject" if testing rejection flow)
   - If validating, the status should change to "PENDING_CHARGE_EXPLOITATION"
   - If rejecting, provide a rejection reason
   - Logout

### 3. Second Validation by Chargé d'exploitation
1. **Login as Chargé d'exploitation**:
   - Matricule: CHARGEX001
   - Password: admin123

2. **Validate and assign the note**:
   - Navigate to the "Pending Notes" page
   - Find the note validated by Chef de Base
   - Review the details
   - Click "Validate"
   - Assign to a Chargé de consignation (select CHARGE001)
   - The status should change to "VALIDATED"
   - Logout

### 4. Consignation Process
1. **Login as Chargé de consignation**:
   - Matricule: CHARGE001
   - Password: admin123

2. **Start consignation**:
   - Navigate to the "Assigned Notes" page
   - Find the assigned note
   - Click "Start Consignation"
   - The consignation start timestamp should be recorded

3. **Complete consignation**:
   - After reviewing the note, click "Complete Consignation"
   - The consignation completion timestamp should be recorded

### 5. Deconsignation Process
1. **Still logged in as Chargé de consignation**:
   - Navigate to the "Consigned Notes" page
   - Find the note with completed consignation
   - Click "Start Deconsignation"
   - The deconsignation start timestamp should be recorded

2. **Complete deconsignation**:
   - After completing the process, click "Complete Deconsignation"
   - The deconsignation completion timestamp should be recorded
   - The workflow is now complete

### 6. Admin Review
1. **Login as Admin**:
   - Matricule: ADMIN001
   - Password: admin123

2. **Review the complete process**:
   - Navigate to the "All Notes" page
   - Find the note that went through the complete workflow
   - Review all timestamps and status changes
   - Check the audit logs for a complete history of actions

---

This documentation provides a comprehensive overview of the workflow processes implemented in the STEG LOTO application. For technical details on implementation, please refer to the codebase and API documentation.
