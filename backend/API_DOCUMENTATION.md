y# STEG LOTO API Documentation

## Authentication

### Login
- **URL**: `/api/auth/login`
- **Method**: `POST`
- **Access**: Public
- **Request Body**:
  ```json
  {
    "matricule": "ADMIN001",
    "password": "admin123"
  }
  ```
- **Response**:
  ```json
  {
    "token": "jwt_token_here",
    "type": "Bearer",
    "id": 1,
    "matricule": "ADMIN001",
    "email": "admin@steg.com.tn",
    "role": "ADMIN"
  }
  ```

### Register
- **URL**: `/api/auth/register`
- **Method**: `POST`
- **Access**: Admin only
- **Request Body**:
  ```json
  {
    "matricule": "USER001",
    "email": "user@steg.com.tn",
    "password": "password123",
    "role": "CHARGE_CONSIGNATION"
  }
  ```
- **Response**:
  ```json
  {
    "id": 4,
    "matricule": "USER001",
    "email": "user@steg.com.tn",
    "role": "CHARGE_CONSIGNATION"
  }
  ```

## Lockout Notes

### Get All Notes
- **URL**: `/api/notes`
- **Method**: `GET`
- **Access**: All authenticated users (ADMIN, CHEF_EXPLOITATION, CHARGE_CONSIGNATION)
- **Response**: Array of lockout notes
  ```json
  [
    {
      "id": "uuid-here",
      "posteHt": "Poste HT 1",
      "status": "DRAFT",
      "createdBy": {
        "id": 1,
        "matricule": "ADMIN001",
        "email": "admin@steg.com.tn",
        "role": "ADMIN"
      },
      "createdAt": "2025-05-09T20:04:33.019",
      "validatedBy": null,
      "validatedAt": null
    }
  ]
  ```

### Get Notes by Status
- **URL**: `/api/notes/status/{status}`
- **Method**: `GET`
- **Access**: All authenticated users
- **Path Parameters**: `status` - One of: DRAFT, PENDING, VALIDATED, REJECTED
- **Response**: Array of lockout notes with the specified status

### Get Note by ID
- **URL**: `/api/notes/{id}`
- **Method**: `GET`
- **Access**: All authenticated users
- **Path Parameters**: `id` - UUID of the note
- **Response**: Single lockout note object

### Create Note
- **URL**: `/api/notes`
- **Method**: `POST`
- **Access**: All authenticated users
- **Request Body**:
  ```json
  {
    "posteHt": "Poste HT 1"
  }
  ```
- **Response**: Created lockout note object

### Validate Note
- **URL**: `/api/notes/{id}/validate`
- **Method**: `PUT`
- **Access**: ADMIN, CHEF_EXPLOITATION
- **Path Parameters**: `id` - UUID of the note
- **Request Body**:
  ```json
  {
    "status": "VALIDATED"
  }
  ```
- **Response**: Updated lockout note object

### Update Note
- **URL**: `/api/notes/{id}`
- **Method**: `PUT`
- **Access**: All authenticated users
- **Path Parameters**: `id` - UUID of the note
- **Request Body**:
  ```json
  {
    "posteHt": "Updated Poste HT"
  }
  ```
- **Response**: Updated lockout note object

### Delete Note
- **URL**: `/api/notes/{id}`
- **Method**: `DELETE`
- **Access**: ADMIN only
- **Path Parameters**: `id` - UUID of the note
- **Response**: 200 OK if successful

## Role-Based Access Control

### User Roles
1. **ADMIN**
   - Can access all endpoints
   - Can create, read, update, validate, and delete notes
   - Can register new users

2. **CHEF_EXPLOITATION**
   - Can create, read, update, and validate notes
   - Cannot delete notes
   - Cannot register new users

3. **CHARGE_CONSIGNATION**
   - Can create, read, and update notes
   - Cannot validate or delete notes
   - Cannot register new users

### Frontend Role Enforcement
The frontend should enforce these access controls by:

1. Hiding UI elements that the user doesn't have permission to access
2. Disabling actions that the user doesn't have permission to perform
3. Checking the user's role before making API calls
4. Handling 403 Forbidden responses gracefully

### Default Users
The application is pre-configured with the following users:

1. **Admin**
   - Matricule: `ADMIN001`
   - Password: `admin123`
   - Role: `ADMIN`

2. **Chef d'exploitation**
   - Matricule: `CHEF001`
   - Password: `admin123`
   - Role: `CHEF_EXPLOITATION`

3. **Chargé de consignation**
   - Matricule: `CHARGE001`
   - Password: `admin123`
   - Role: `CHARGE_CONSIGNATION`
