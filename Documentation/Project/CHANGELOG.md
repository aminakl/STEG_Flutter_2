# STEG LOTO - Changelog

## Version 1.2.0 (2025-05-19)

### Enhanced Consignation Process
- ✅ Implemented standardized maneuver sheets for different equipment types (LIGNE_HT, TRANSFORMATEUR, COUPLAGE)
- ✅ Added interactive electrical schema manipulation with GND and INTERRUPTEUR elements
- ✅ Implemented step-by-step tracking of consignation and deconsignation procedures with timing metrics
- ✅ Added EPI (Équipement de Protection Individuelle) verification checklist
- ✅ Implemented work attestation generation and management
- ✅ Added PDF generation for completed maneuver sheets

### Database Enhancements
- ✅ Extended database schema to support equipment types and detailed note information
- ✅ Added tables for maneuver sheets, consignation steps, schema modifications, and EPI verification
- ✅ Implemented work attestation tracking
- ✅ Enhanced user model with additional fields (full name, phone number, unit)

### Backend Improvements
- ✅ Created comprehensive model classes for the enhanced consignation process
- ✅ Implemented repository interfaces for new data entities
- ✅ Added DTOs for data transfer between frontend and backend
- ✅ Implemented services for maneuver sheet and work attestation management
- ✅ Created controllers with proper role-based access control
- ✅ Added file storage service for schema images and PDF documents

### Frontend Enhancements
- ✅ Implemented equipment type selection during note creation
- ✅ Created interactive canvas for electrical schema manipulation
- ✅ Added step-by-step consignation procedure interface
- ✅ Implemented EPI verification checklist UI
- ✅ Created work attestation management screens
- ✅ Enhanced dashboard with consignation progress metrics

### Role-Based Access Enhancements
- ✅ Added CHARGE_TRAVAUX role for work personnel
- ✅ Updated role-based permissions for the new features
- ✅ Implemented specific views for different roles in the consignation process

## Version 1.1.1 (2025-05-10)

### Connectivity & Error Handling Improvements
- ✅ Fixed API connectivity issues by updating API URLs to use 10.0.2.2 for Android emulator
- ✅ Enhanced error handling in notification service to prevent crashes
- ✅ Improved AdminDashboardService with proper error handling and fallback data
- ✅ Fixed UI overflow issues in notification screen and admin dashboard
- ✅ Updated notification provider to handle connection errors gracefully

## Version 1.1.0 (2025-05-09)

### Role-Based Access Enhancements
- ✅ Added new user roles: CHEF_DE_BASE and CHARGE_EXPLOITATION
- ✅ Updated role-based permissions to support multi-stage validation
- ✅ Enhanced RoleBasedAccess utility with role-specific permission methods
- ✅ Implemented comprehensive validation workflow with proper role checks

### Workflow Improvements
- ✅ Implemented multi-stage validation process (Draft → Pending Chef Base → Pending Charge Exploitation → Validated)
- ✅ Added note assignment functionality for Charge Exploitation users
- ✅ Implemented consignation and deconsignation process tracking
- ✅ Added detailed rejection reasons and equipment details
- ✅ Created ConsignationController with endpoints for the entire workflow

### Frontend Updates
- ✅ Updated API service to support new endpoints
- ✅ Enhanced models to handle new fields and statuses
- ✅ Updated UI to reflect the new workflow stages

## Version 1.0.0 (2025-05-08)

### Authentication & Security
- ✅ Fixed JWT authentication in the backend
- ✅ Implemented proper role-based access control (RBAC)
- ✅ Secured endpoints with appropriate role permissions
- ✅ Added JWT token validation and refresh mechanisms
- ✅ Implemented secure password storage with BCrypt

### Backend Improvements
- ✅ Fixed CORS configuration to allow requests from any origin
- ✅ Enhanced error handling in controllers with proper HTTP status codes
- ✅ Added comprehensive API documentation
- ✅ Fixed lazy-loading issues with JPA entities
- ✅ Added user management endpoint for administrators
- ✅ Implemented audit logging with MongoDB

### Frontend Features
- ✅ Implemented user authentication flow
- ✅ Created lockout note management system
- ✅ Added role-based UI components
- ✅ Implemented note status workflow (Draft → Pending → Validated/Rejected)
- ✅ Added user management screen for administrators
- ✅ Implemented real-time UI updates when note statuses change

### UI/UX Enhancements
- ✅ Added navigation drawer with role-based menu items
- ✅ Implemented status indicators with color coding
- ✅ Added confirmation dialogs for destructive actions
- ✅ Improved error messages and feedback
- ✅ Enhanced form validation
- ✅ Fixed layout issues on different screen sizes

### Bug Fixes
- ✅ Fixed 403 error when fetching notes
- ✅ Fixed 400 error when registering users
- ✅ Resolved issues with note list not refreshing after status changes
- ✅ Fixed JSON parsing errors in User and LockoutNote models
- ✅ Resolved UI layout issues and banner display problems
- ✅ Fixed navigation issues after note status changes

### Documentation
- ✅ Created comprehensive API documentation
- ✅ Added setup instructions for backend and frontend
- ✅ Documented role-based access control system
- ✅ Created this changelog to track progress

### DevOps
- 🔲 Set up Docker Compose for easy deployment
- 🔲 Implement CI/CD pipeline
- 🔲 Add automated testing
- 🔲 Set up monitoring and logging
- 🔲 Implement backup and restore functionality
