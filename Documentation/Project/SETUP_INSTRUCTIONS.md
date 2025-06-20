# STEG LOTO App Setup Instructions

This document provides step-by-step instructions for setting up and running the STEG LOTO application.

## Prerequisites

Ensure you have the following installed:
- Java JDK 17+
- Flutter SDK 3.13+
- Docker and Docker Compose
- Maven 3.9+
- Git

## Database Setup

### Using Docker (Recommended)

1. Start the PostgreSQL database and pgAdmin using Docker Compose:

```bash
docker-compose up -d
```

This will start:
- PostgreSQL on port 5432
- pgAdmin on port 5050 (accessible at http://localhost:5050)

2. Access pgAdmin:
   - URL: http://localhost:5050
   - Email: admin@steg.com
   - Password: admin

3. Connect to PostgreSQL in pgAdmin:
   - Right-click on "Servers" in the left panel and select "Create" > "Server"
   - In the "General" tab, enter "STEG LOTO" as the name
   - In the "Connection" tab, enter:
     - Host: postgres (or localhost if accessing outside Docker)
     - Port: 5432
     - Maintenance database: loto_db
     - Username: postgres
     - Password: root
   - Click "Save"

### Manual PostgreSQL Setup

If you prefer to use your existing PostgreSQL installation:

1. Open PostgreSQL command line:
```bash
psql -U postgres
```

2. Create the database:
```sql
CREATE DATABASE loto_db;
```

3. Connect to the database:
```sql
\c loto_db
```

4. Run the schema.sql script:
```bash
psql -U postgres -d loto_db -f backend/src/main/resources/schema.sql
```

## MongoDB Setup

The application is already configured to use the MongoDB Atlas cluster with the following connection string:
```
mongodb+srv://fedimechergui03:IKRB1w8GebUNDdMX@cluster0.yvrsglh.mongodb.net/steg_loto?retryWrites=true&w=majority&appName=Cluster0
```

No additional setup is required for MongoDB.

## Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Build the application:
```bash
mvn clean install
```

3. Run the application:
```bash
mvn spring-boot:run
```

The backend will start on http://localhost:8080

## Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Default Users

The application is pre-configured with the following users. All users have the same password: `admin123`.

1. Admin:
   - **Matricule**: ADMIN001
   - **Password**: admin123
   - **Role**: ADMIN
   - **Email**: admin@steg.com.tn

2. Chef d'exploitation:
   - **Matricule**: CHEF001
   - **Password**: admin123
   - **Role**: CHEF_EXPLOITATION
   - **Email**: chef@steg.com.tn

3. Chef de Base:
   - **Matricule**: BASE001
   - **Password**: admin123
   - **Role**: CHEF_DE_BASE
   - **Email**: base@steg.com.tn

4. Chargé d'exploitation:
   - **Matricule**: CHARGEX001
   - **Password**: admin123
   - **Role**: CHARGE_EXPLOITATION
   - **Email**: chargex@steg.com.tn

5. Chargé de consignation:
   - **Matricule**: CHARGE001
   - **Password**: admin123
   - **Role**: CHARGE_CONSIGNATION
   - **Email**: charge@steg.com.tn

## Role-Based Access Control

The application implements comprehensive role-based access control to restrict access to certain features based on the user's role and support the multi-stage validation workflow.

### Roles and Permissions

1. **ADMIN**: Has access to all features and can perform any action.
2. **CHEF_EXPLOITATION**: Can create notes and submit them for validation.
3. **CHEF_DE_BASE**: Can validate or reject notes submitted by Chef d'exploitation.
4. **CHARGE_EXPLOITATION**: Can assign validated notes to Chargé de consignation.
5. **CHARGE_CONSIGNATION**: Can perform consignation and deconsignation processes.

### Backend Implementation

The backend enforces role-based access control through Spring Security. The security configuration is defined in `SecurityConfig.java`.

Endpoints are secured as follows:
- `/api/auth/**`: Public access for authentication
- `/api/notes/**`: Access based on specific role requirements
- `/api/notes/{id}/validate`: Requires ADMIN, CHEF_DE_BASE, or CHARGE_EXPLOITATION roles
- `/api/notes/{id}/assign`: Requires ADMIN or CHARGE_EXPLOITATION roles
- `/api/notes/{id}/consignation/**`: Requires ADMIN or CHARGE_CONSIGNATION roles
- `/api/notes/{id}/deconsignation/**`: Requires ADMIN or CHARGE_CONSIGNATION roles

Detailed API documentation can be found in the `backend/API_DOCUMENTATION.md` file.

### Frontend Implementation

The frontend enforces role-based access control through the enhanced `RoleBasedAccess` utility class in `lib/utils/role_based_access.dart`. This class provides methods to check if the current user has permission to perform specific actions in the workflow.

Role-specific permission methods include:
- `isChefDeBase()`: Checks if the user is a Chef de Base
- `isChargeExploitation()`: Checks if the user is a Chargé d'exploitation
- `canValidateAsChefDeBase()`: Checks if the user can validate notes as a Chef de Base
- `canValidateAsChargeExploitation()`: Checks if the user can validate notes as a Chargé d'exploitation
- `canAssignNotes()`: Checks if the user can assign notes to Chargé de consignation
- `canPerformConsignation()`: Checks if the user can perform consignation
- `canPerformDeconsignation()`: Checks if the user can perform deconsignation

UI elements are conditionally displayed based on the user's role and the current stage of the workflow:
- Only Chef d'exploitation and admins can create notes
- Only Chef de Base and admins can validate notes at the first stage
- Only Chargé d'exploitation and admins can validate notes at the second stage and assign them
- Only Chargé de consignation and admins can perform consignation and deconsignation
- Only admins can delete notes

## Troubleshooting

### Database Connection Issues

If you encounter database connection issues:

1. Verify that PostgreSQL is running:
```bash
docker ps
```

2. Check the application.properties file to ensure the connection details are correct:
```
spring.datasource.url=jdbc:postgresql://localhost:5432/loto_db
spring.datasource.username=postgres
spring.datasource.password=root
```

3. If you're using a local PostgreSQL installation, make sure it's running on port 5432.

### Flutter Build Issues

If you encounter Flutter build issues:

1. Make sure you have the latest Flutter SDK:
```bash
flutter upgrade
```

2. Clean the Flutter project:
```bash
flutter clean
flutter pub get
```

3. Check for any platform-specific issues:
```bash
flutter doctor
```
