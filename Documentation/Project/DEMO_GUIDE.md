# STEG LOTO Application Demo Guide

This guide provides step-by-step instructions for demonstrating the STEG LOTO application, including all the features implemented so far.

## Prerequisites

- Java 17+ for the backend
- Flutter SDK for the frontend
- MySQL database

## Starting the Application

### 1. Start the Backend

```bash
cd backend
./mvnw spring-boot:run
```

### 2. Start the Frontend

```bash
cd frontend
flutter run -d windows
```

Alternatively, you can use the provided batch file:

```bash
run_app.bat
```

## Demo Workflow

Follow this step-by-step guide to demonstrate the complete workflow of the STEG LOTO application.

### 1. Authentication

1. Launch the application
2. Log in with one of the following test accounts:
   - ADMIN001 / admin123 (ADMIN role)
   - CHEF001 / admin123 (CHEF_EXPLOITATION role)
   - BASE001 / admin123 (CHEF_DE_BASE role)
   - CHARGEX001 / admin123 (CHARGE_EXPLOITATION role)
   - CHARGE001 / admin123 (CHARGE_CONSIGNATION role)

### 2. Lockout Note Creation (CHEF_EXPLOITATION)

1. Log in as CHEF001 (CHEF_EXPLOITATION role)
2. Navigate to "Create Note" from the drawer menu
3. Fill in the required fields:
   - Poste HT: "Poste HT Rades"
   - Equipment Details: "Transformer T1, Circuit Breaker CB-101"
4. Submit the note 
5. Observe that the note is created with "DRAFT" status
6. Submit the note for validation
7. Observe that the note status changes to "PENDING_CHEF_BASE"

### 3. First Stage Validation (CHEF_DE_BASE)

1. Log out and log in as BASE001 (CHEF_DE_BASE role)
2. Navigate to "Home" to see pending notes
3. Select the note created in the previous step
4. Review the note details
5. Click "Validate" to approve the note
6. Observe that the note status changes to "PENDING_CHARGE_EXPLOITATION"

### 4. Second Stage Validation (CHARGE_EXPLOITATION)

1. Log out and log in as CHARGEX001 (CHARGE_EXPLOITATION role)
2. Navigate to "Home" to see pending notes
3. Select the note that was validated by CHEF_DE_BASE
4. Review the note details
5. Click "Validate" to approve the note
6. Assign the note to a CHARGE_CONSIGNATION user
7. Observe that the note status changes to "VALIDATED" and is assigned

### 5. Consignation Process (CHARGE_CONSIGNATION)

1. Log out and log in as CHARGE001 (CHARGE_CONSIGNATION role)
2. Navigate to "Home" to see assigned notes
3. Select the assigned note
4. Click "Start Consignation" to begin the process
5. Observe that the consignation start time is recorded
6. Complete the consignation process
7. Observe that the consignation completion time is recorded

### 6. Deconsignation Process (CHARGE_CONSIGNATION)

1. While still logged in as CHARGE001
2. Navigate to "Home" to see consigned notes
3. Select the consigned note
4. Click "Start Deconsignation" to begin the process
5. Observe that the deconsignation start time is recorded
6. Complete the deconsignation process
7. Observe that the deconsignation completion time is recorded

### 7. Notifications

1. Log in as any user
2. Navigate to "Notifications" from the drawer menu
3. Observe the list of notifications related to the user's activities
4. Click on a notification to mark it as read
5. Use the "Mark All as Read" button to mark all notifications as read

### 8. Admin Dashboard (ADMIN)

1. Log in as ADMIN001 (ADMIN role)
2. Navigate to "Admin Dashboard" from the drawer menu
3. Explore the different tabs:
   - Overview: General statistics, notes by status, users by role
   - Monthly Trends: Notes created per month, status distribution over time
   - User Performance: Activity metrics by user and role

## Key Features Implemented

### 1. Multi-Stage Validation Process
- Draft → Pending Chef Base → Pending Charge Exploitation → Validated/Rejected
- Role-based validation permissions
- Rejection with reason

### 2. Consignation/Deconsignation Workflow
- Assignment to specific users
- Start and completion time tracking
- Status tracking throughout the process

### 3. In-App Notification System
- Real-time notifications for workflow events
- Note creation, validation, and rejection notifications
- Assignment notifications
- Consignation and deconsignation process updates
- Read/unread status tracking

### 4. Admin KPI Dashboard
- Process metrics (validation time, completion rate)
- User activity metrics
- Status distribution and trends
- Monthly statistics

### 5. Role-Based Access Control
- ADMIN: Full access to all features
- CHEF_EXPLOITATION: Creates lockout notes
- CHEF_DE_BASE: First stage validation
- CHARGE_EXPLOITATION: Second stage validation and assignment
- CHARGE_CONSIGNATION: Performs consignation process

## Troubleshooting

If you encounter any issues:

1. Ensure the backend is running and accessible
2. Check database connection settings
3. Verify that the API base URL is correctly configured in the frontend
4. Clear application cache if needed
5. Check the logs for specific error messages

For any persistent issues, please contact the development team.
