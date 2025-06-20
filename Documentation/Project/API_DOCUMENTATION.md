# STEG LOTO Application API Documentation

## Authentication Endpoints

### Login
- **URL**: `/api/auth/login`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "matricule": "USER001",
    "password": "password123"
  }
  ```
- **Response**: JWT token and user details

### Register
- **URL**: `/api/auth/register`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "matricule": "USER002",
    "email": "user@steg.com.tn",
    "password": "password123",
    "role": "CHARGE_TRAVAUX",
    "fullName": "User Name",
    "phoneNumber": "+216 xx xxx xxx",
    "unit": "Unit Name"
  }
  ```
- **Response**: Success message

## Lockout Note Endpoints

### Create Note
- **URL**: `/api/notes`
- **Method**: `POST`
- **Authorization**: Required (CHEF_EXPLOITATION, ADMIN)
- **Request Body**:
  ```json
  {
    "uniteSteg": "Unité Nord",
    "posteHt": "Poste HT-1",
    "posteRecepteur": "Poste R-1",
    "equipmentType": "LIGNE_HT",
    "workDescription": "Description of work",
    "equipmentDetails": "Equipment details",
    "chargeTravaux": 5,
    "chargeRetrait": 3,
    "chargeEssais": 4,
    "retraitDate": "2025-05-20T08:00:00",
    "travauxDebutDate": "2025-05-20T10:00:00",
    "travauxFinDate": "2025-05-21T16:00:00",
    "retourDate": "2025-05-21T18:00:00",
    "joursIndisponibilite": 2,
    "instructionsTechniques": "Technical instructions",
    "instructionsTravaux": "Work instructions"
  }
  ```
- **Response**: Created note details

### Get Note by ID
- **URL**: `/api/notes/{id}`
- **Method**: `GET`
- **Authorization**: Required
- **Response**: Note details with maneuver sheets

### Get All Notes
- **URL**: `/api/notes`
- **Method**: `GET`
- **Authorization**: Required
- **Query Parameters**:
  - `status`: Filter by status (DRAFT, PENDING_CHEF_BASE, etc.)
  - `equipmentType`: Filter by equipment type (LIGNE_HT, TRANSFORMATEUR, COUPLAGE)
- **Response**: List of notes

### Update Note Status
- **URL**: `/api/notes/{id}/status`
- **Method**: `PUT`
- **Authorization**: Required
- **Request Body**:
  ```json
  {
    "status": "VALIDATED",
    "rejectionReason": null
  }
  ```
- **Response**: Updated note

### Assign Note
- **URL**: `/api/notes/{id}/assign`
- **Method**: `PUT`
- **Authorization**: Required (CHARGE_EXPLOITATION)
- **Request Body**:
  ```json
  {
    "userId": 3
  }
  ```
- **Response**: Success message

## Maneuver Sheet Endpoints

### Create Maneuver Sheet
- **URL**: `/api/maneuver-sheets`
- **Method**: `POST`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Query Parameters**:
  - `noteId`: UUID of the lockout note
  - `equipmentType`: Equipment type (LIGNE_HT, TRANSFORMATEUR, COUPLAGE)
- **Response**: Created maneuver sheet details

### Get Maneuver Sheet by ID
- **URL**: `/api/maneuver-sheets/{id}`
- **Method**: `GET`
- **Authorization**: Required
- **Response**: Maneuver sheet details with consignation steps, schema modifications, and EPI verification

### Get Maneuver Sheets by Note ID
- **URL**: `/api/maneuver-sheets/note/{noteId}`
- **Method**: `GET`
- **Authorization**: Required
- **Response**: List of maneuver sheets for the note

### Update Schema Modification
- **URL**: `/api/maneuver-sheets/schema-modifications`
- **Method**: `POST`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Request Body**:
  ```json
  {
    "id": null,
    "maneuverSheetId": "uuid-here",
    "elementType": "GND",
    "xPosition": 150.5,
    "yPosition": 200.7,
    "rotation": 0
  }
  ```
- **Query Parameters**:
  - `userId`: ID of the user making the modification (optional)
- **Response**: Schema modification details

### Complete Consignation Step
- **URL**: `/api/maneuver-sheets/consignation-steps/{stepId}/complete`
- **Method**: `POST`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Response**: Completed step details

### Update EPI Verification
- **URL**: `/api/maneuver-sheets/{maneuverSheetId}/epi-verification`
- **Method**: `POST`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Request Body**:
  ```json
  {
    "casqueIsolant": true,
    "gantsIsolants": true,
    "ecranFacial": true,
    "vetementsIgnifuges": true,
    "chaussuresDielectriques": true
  }
  ```
- **Query Parameters**:
  - `userId`: ID of the user verifying EPI
- **Response**: Updated EPI verification details

### Generate PDF
- **URL**: `/api/maneuver-sheets/{maneuverSheetId}/generate-pdf`
- **Method**: `POST`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Query Parameters**:
  - `userId`: ID of the user generating the PDF (optional)
- **Response**: Path to the generated PDF

## File Management Endpoints

### Upload File
- **URL**: `/api/files/upload`
- **Method**: `POST`
- **Authorization**: Required (ROLE_ADMIN, ROLE_CHARGE_CONSIGNATION, ROLE_CHEF_EXPLOITATION)
- **Form Data**:
  - `file`: The file to upload
  - `fileCategory`: Category of the file (SCHEMA, MODIFIED_SCHEMA, PDF)
  - `maneuverSheetId`: UUID of related maneuver sheet (optional)
  - `userId`: ID of the user uploading (optional)
  - `description`: Description of the file (optional)
- **Response**: File details with download URL

### Download File
- **URL**: `/api/files/download/{fileName}`
- **Method**: `GET`
- **Response**: File download

### Get Files by Maneuver Sheet
- **URL**: `/api/files/maneuver-sheet/{maneuverSheetId}`
- **Method**: `GET`
- **Authorization**: Required
- **Response**: List of files associated with the maneuver sheet

### Get Schema Template
- **URL**: `/api/files/schemas/template/{equipmentType}`
- **Method**: `GET`
- **Response**: Schema template file details

### Delete File
- **URL**: `/api/files/{fileId}`
- **Method**: `DELETE`
- **Authorization**: Required (ROLE_ADMIN, ROLE_CHARGE_CONSIGNATION)
- **Response**: Success message

## Work Attestation Endpoints

### Create Work Attestation
- **URL**: `/api/work-attestations`
- **Method**: `POST`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Request Body**:
  ```json
  {
    "noteId": "uuid-here",
    "issuedTo": 5,
    "issuedBy": 3
  }
  ```
- **Response**: Created work attestation

### Get Attestations by Note
- **URL**: `/api/work-attestations/note/{noteId}`
- **Method**: `GET`
- **Authorization**: Required
- **Response**: List of work attestations for the note

### Revoke Attestation
- **URL**: `/api/work-attestations/{id}/revoke`
- **Method**: `PUT`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Response**: Updated attestation

### Extend Attestation Validity
- **URL**: `/api/work-attestations/{id}/extend`
- **Method**: `PUT`
- **Authorization**: Required (ADMIN, CHARGE_CONSIGNATION)
- **Request Body**:
  ```json
  {
    "hours": 24
  }
  ```
- **Response**: Updated attestation with new validity period

## Notification Endpoints

### Get User Notifications
- **URL**: `/api/notifications`
- **Method**: `GET`
- **Authorization**: Required
- **Response**: List of notifications for current user

### Mark Notification as Read
- **URL**: `/api/notifications/{id}/read`
- **Method**: `PUT`
- **Authorization**: Required
- **Response**: Updated notification

### Mark All Notifications as Read
- **URL**: `/api/notifications/read-all`
- **Method**: `PUT`
- **Authorization**: Required
- **Response**: Success message
