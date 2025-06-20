# STEG LOTO - Changelog

## Version 1.1.3 (2025-05-21)

### Note Management Enhancements
- ✅ Improved note details display with comprehensive information sections
- ✅ Added clear visualization of rejection reasons for rejected notes
- ✅ Implemented functionality for Chef d'Exploitation to return rejected notes to draft status
- ✅ Added option to discard rejected notes
- ✅ Enhanced notification system to ensure Chef d'Exploitation receives notifications when notes are rejected
- ✅ Fixed permission issues in the backend for note status transitions
- ✅ Improved UI with card-based layout for better organization of note details
- ✅ Added detailed logging for better debugging and troubleshooting
- ✅ Fixed UI overflow issues in note details screen

## Version 1.1.2 (2025-05-20)

### Equipment Type & Notification Optimization
- ✅ Fixed equipment type format mismatch between frontend and backend
- ✅ Ensured consistent handling of equipment types across the application
- ✅ Optimized notification polling to reduce server load and improve performance
- ✅ Implemented client-side notification filtering to reduce API calls
- ✅ Added caching for notifications to improve app responsiveness
- ✅ Fixed permission issues related to equipment type format

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
