# HT Post Lockout/Tagout (LOTO) Mobile Application

**Client:** Tunisian Electricity and Gas Company (STEG)  
**Objective:** Digitize and automate lockout/tagout procedures for high-voltage electrical posts to improve safety, compliance, and operational efficiency.

## Table of Contents
- [Project Architecture](#project-architecture)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Database Configuration](#database-configuration)
- [Backend Implementation](#backend-implementation)
- [Frontend Implementation](#frontend-implementation)
- [Authentication & Security](#authentication--security)
- [Workflow Automation](#workflow-automation)
- [Notification System](#notification-system)
- [Admin Dashboard](#admin-dashboard)
- [Testing](#testing)
- [Deployment](#deployment)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Usage Examples](#usage-examples)

## Project Architecture
### System Overview
Architecture Diagram

- **Frontend:** Flutter (Dart) with Riverpod for state management (MVVM pattern).
- **Backend:** Spring Boot (Java) with REST APIs, Spring Security, and Spring Data JPA.
- **Databases:**
  - PostgreSQL: Structured data (users, lockout notes, permissions).
  - MongoDB: Audit logs, system metrics, unstructured data.
- **DevOps:** Docker, Kubernetes, Jenkins CI/CD.
- **Monitoring:** Prometheus (metrics), Grafana (dashboards), Loki (logs).

## Prerequisites
### Software & Tools
Development:
- Java JDK 17+
- Flutter SDK 3.13+
- Android Studio / VS Code
- Node.js 18+ (for Firebase CLI)
- Maven 3.9+

Databases:
- PostgreSQL 15+
- MongoDB 7.0+

Infrastructure:
- Docker 24.0+
- Kubernetes 1.28+
- Jenkins 2.414+

APIs & Testing:
- Postman / Insomnia
- Swagger OpenAPI 3.0

## Installation & Setup
### 1. Clone the Repository
```bash
git clone https://github.com/your-org/steg-loto-app.git  
cd steg-loto-app  
```

### 2. Backend Setup (Spring Boot)
```bash
cd backend  
mvn clean install  
```

Key Dependencies:
```xml
<dependency>  
  <groupId>org.springframework.boot</groupId>  
  <artifactId>spring-boot-starter-security</artifactId>  
</dependency>  
<dependency>  
  <groupId>io.jsonwebtoken</groupId>  
  <artifactId>jjwt-api</artifactId>  
  <version>0.11.5</version>  
</dependency>  
<dependency>  
  <groupId>org.postgresql</groupId>  
  <artifactId>postgresql</artifactId>  
</dependency>  
```

### 3. Frontend Setup (Flutter)
```bash
cd frontend  
flutter pub get  
```

Key Dependencies:
```yaml
dependencies:  
  flutter_riverpod: ^2.3.6  
  dio: ^5.3.2  
  firebase_core: ^2.14.0  
  firebase_auth: ^4.9.0  
```

### 4. Environment Variables
Create .env files:

Backend:
```properties
# .env  
DATABASE_URL=jdbc:postgresql://localhost:5432/loto_db  
JWT_SECRET=steg_secure_key_2024  
FIREBASE_API_KEY=your_firebase_key  
```

Frontend:
```dart
// lib/config/env.dart  
const String API_BASE_URL = "http://localhost:8080";  
const String FIREBASE_PROJECT_ID = "steg-loto-app";  
```

## Database Configuration
### PostgreSQL Schema
```sql
CREATE TABLE users (  
  id SERIAL PRIMARY KEY,  
  matricule VARCHAR(20) UNIQUE,  
  email VARCHAR(255) UNIQUE,  
  role VARCHAR(50) NOT NULL, -- ADMIN, CHEF_EXPLOITATION, CHEF_DE_BASE, CHARGE_EXPLOITATION, CHARGE_CONSIGNATION  
  password_hash VARCHAR(255),  
  is_active BOOLEAN DEFAULT true  
);  

CREATE TABLE lockout_notes (  
  id UUID PRIMARY KEY,  
  poste_ht VARCHAR(100) NOT NULL,  
  equipment_details TEXT,  
  status VARCHAR(50) CHECK (status IN ('DRAFT', 'PENDING_CHEF_BASE', 'PENDING_CHARGE_EXPLOITATION', 'VALIDATED', 'REJECTED')),  
  created_by INT REFERENCES users(id),  
  validated_by_chef_base INT REFERENCES users(id),  
  validated_by_charge_exploitation INT REFERENCES users(id),  
  rejection_reason TEXT,  
  assigned_to INT REFERENCES users(id),  
  assigned_at TIMESTAMP,  
  consignation_started_at TIMESTAMP,  
  consignation_completed_at TIMESTAMP,  
  deconsignation_started_at TIMESTAMP,  
  deconsignation_completed_at TIMESTAMP  
);  
```

### MongoDB Collections
```javascript
// audit_logs collection  
{  
  "action": "NOTE_VALIDATED",  
  "userId": "admin-123",  
  "timestamp": ISODate("2024-02-15T10:00:00Z"),  
  "details": { "noteId": "uuid-123", "comments": "Approved for maintenance" }  
}  
```

## Backend Implementation
### Key Components
REST API Endpoints:
- POST /api/auth/login (JWT authentication)
- POST /api/notes (Create lockout note)
- PUT /api/notes/{id}/validate (Validate/reject note)

Spring Security Configuration:
```java
@Configuration  
@EnableWebSecurity  
public class SecurityConfig {  
  @Bean  
  public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {  
    http  
      .csrf().disable()  
      .authorizeHttpRequests(auth -> auth  
        .requestMatchers("/api/auth/**").permitAll()  
        .requestMatchers("/api/notes/**").hasRole("CHEF_EXPLOITATION")  
      )  
      .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))  
      .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);  
    return http.build();  
  }  
}  
```

## Frontend Implementation
### Key Screens
Authentication Flow:
- Login with Matricule/Password (JWT token storage via flutter_secure_storage).

Lockout Note Creation:
- Form with dynamic fields for poste HT, equipment, and assigned personnel.

Real-Time Dashboard:
- Riverpod state management to sync data with backend.

```dart
// Example: Lockout note creation  
class LockoutNoteForm extends ConsumerWidget {  
  @override  
  Widget build(BuildContext context, WidgetRef ref) {  
    final noteProvider = ref.watch(lockoutNoteController);  
    return Form(  
      child: Column(  
        children: [  
          TextFormField(  
            decoration: InputDecoration(labelText: "Poste HT"),  
            onChanged: (value) => noteProvider.updatePosteHT(value),  
          ),  
          ElevatedButton(  
            onPressed: () => noteProvider.submitNote(),  
            child: Text("Submit"),  
          ),  
        ],  
      ),  
    );  
  }  
}  
```

## Authentication & Security
### JWT Flow:
- User logs in → Backend returns JWT → Token stored in secure storage.

### Role-Based Access Control (RBAC):
- Define roles in PostgreSQL (ADMIN, CHEF_EXPLOITATION, CHEF_DE_BASE, CHARGE_EXPLOITATION, CHARGE_CONSIGNATION).
- Each role has specific permissions in the workflow process.

### Password Policies:
- 12+ characters, 1 uppercase, 1 number, 1 symbol.
- BCrypt hashing with salt.

## Workflow Automation
### Lockout Note Validation
Enhanced Multi-Stage Validation Workflow:
1. Chef d'exploitation creates a note with equipment details (status: DRAFT).
2. Note is submitted for validation to Chef de Base (status: PENDING_CHEF_BASE).
3. Chef de Base validates or rejects with detailed reasons (if validated, status: PENDING_CHARGE_EXPLOITATION).
4. Chargé d'exploitation reviews and assigns to a Chargé de consignation (status: VALIDATED).
5. Chargé de consignation receives the assignment and performs the consignation process.

### Consignation Process
Consignation Workflow:
1. Chargé de consignation starts the consignation process (consignation_started_at timestamp recorded).
2. Completes the consignation process (consignation_completed_at timestamp recorded).
3. Later starts the deconsignation process (deconsignation_started_at timestamp recorded).
4. Completes the deconsignation process (deconsignation_completed_at timestamp recorded).

## Notification System
### In-App Notifications
The application includes a comprehensive in-app notification system to keep users informed about important events and status changes:

- **Real-time Updates**: Users receive notifications for note creation, validation, rejection, assignment, and consignation/deconsignation events.
- **Notification Types**: Different types of notifications with appropriate icons and colors for easy identification.
- **Read/Unread Status**: Notifications track read status to help users manage their workflow.
- **Notification Center**: Dedicated screen to view all notifications with filtering options.

### Implementation Details
```java
// Backend Notification Service
public Notification createNotification(String title, String message, NotificationType type, User user, UUID relatedNoteId) {
    Notification notification = new Notification();
    notification.setTitle(title);
    notification.setMessage(message);
    notification.setType(type);
    notification.setUser(user);
    notification.setRelatedNoteId(relatedNoteId);
    notification.setRead(false);
    notification.setCreatedAt(LocalDateTime.now());
    return notificationRepository.save(notification);
}
```

```dart
// Frontend Notification Provider
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Notification> _notifications = [];
  int _unreadCount = 0;
  
  Future<void> fetchNotifications() async {
    try {
      _notifications = await _notificationService.getUserNotifications();
      _unreadCount = _notifications.where((n) => !n.read).length;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
```

## Admin Dashboard
### Key Performance Indicators
The admin dashboard provides comprehensive metrics and analytics to monitor the system's performance:

- **Process Metrics**: Average validation time, average consignation time, and completion rates.
- **Status Distribution**: Visual representation of notes by status (Draft, Pending, Validated, Rejected).
- **Monthly Trends**: Charts showing note creation and validation trends over time.
- **User Performance**: Activity metrics by user and role to identify bottlenecks and high performers.

### Implementation Details
```java
// Backend Admin Dashboard Controller
@GetMapping("/stats")
public ResponseEntity<Map<String, Object>> getDashboardStats() {
    Map<String, Object> stats = new HashMap<>();
    
    // Get notes by status
    Map<String, Long> notesByStatus = lockoutNoteRepository.countByStatusGrouped();
    stats.put("notesByStatus", notesByStatus);
    
    // Get users by role
    Map<String, Long> usersByRole = userRepository.countByRoleGrouped();
    stats.put("usersByRole", usersByRole);
    
    // Calculate average validation time
    double avgValidationTime = lockoutNoteRepository.calculateAverageValidationTime();
    stats.put("avgValidationTime", avgValidationTime);
    
    return ResponseEntity.ok(stats);
}
```

```dart
// Frontend Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDashboardService _dashboardService = AdminDashboardService();
  Map<String, dynamic> _dashboardStats = {};
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    final dashboardStats = await _dashboardService.getDashboardStats();
    setState(() {
      _dashboardStats = dashboardStats;
    });
  }
}
```

## Testing
### Unit Tests
Backend:
```java
@Test  
public void testNoteValidation() {  
  LockoutNote note = new LockoutNote("POSTE-225kV-01", "DRAFT");  
  noteService.validateNote(note.getId(), "VALIDATED", "admin-123");  
  assertEquals("VALIDATED", note.getStatus());  
}  
```

Frontend:
```dart
testWidgets('Lockout note submission', (tester) async {  
  await tester.pumpWidget(ProviderScope(child: MyApp()));  
  await tester.enterText(find.byType(TextFormField), "POSTE-225kV-01");  
  await tester.tap(find.text("Submit"));  
  expect(find.text("Note submitted"), findsOneWidget);  
});  
```

### API Testing (Postman)
- Import Postman Collection.
- Test scenarios: Authentication, note creation/validation, error handling.

## Deployment
### Docker & Kubernetes
Backend Dockerfile:
```dockerfile
FROM openjdk:17-jdk-slim  
COPY target/backend-0.0.1-SNAPSHOT.jar app.jar  
ENTRYPOINT ["java", "-jar", "/app.jar"]  
```

Kubernetes Deployment:
```yaml
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  name: loto-backend  
spec:  
  replicas: 3  
  template:  
    spec:  
      containers:  
      - name: backend  
        image: steg-loto-backend:1.0  
        ports:  
        - containerPort: 8080  
```

### Jenkins Pipeline
```groovy
pipeline {  
  agent any  
  stages {  
    stage('Build Backend') {  
      steps {  
        sh 'mvn clean package'  
      }  
    }  
    stage('Deploy to Kubernetes') {  
      steps {  
        sh 'kubectl apply -f k8s/deployment.yaml'  
      }  
    }  
  }  
}  
```

## Monitoring & Maintenance
### Prometheus Metrics:
- Scrape Spring Boot Actuator endpoints every 15s.

### Grafana Dashboard:
- Track API response times, error rates, and user activity.

### Logging:
- Centralize logs in Loki + Grafana.

## Usage Examples
### Creating a Lockout Note
1. Login as Chef d'exploitation.
2. Navigate to New Note → Fill in poste HT, equipment details, and other required information.
3. Submit → Note moves to PENDING_CHEF_BASE status.
4. The system generates a notification for the Chef de Base users about the new note pending validation.

### Validating a Note (Chef de Base)
1. Login as Chef de Base.
2. Check notifications for pending validations.
3. Open Pending Notes → Review details → Approve/Reject with comments.
4. If approved, note moves to PENDING_CHARGE_EXPLOITATION status.
5. The system generates a notification for Charge Exploitation users about the note pending their validation.

### Assigning a Note
1. Login as Chargé d'exploitation.
2. Check notifications for notes pending assignment.
3. View validated notes → Assign to a Chargé de consignation.
4. Chargé de consignation receives notification of assignment.

### Performing Consignation
1. Login as Chargé de consignation.
2. Check notifications for newly assigned notes.
3. View assigned notes → Start consignation process.
4. Complete consignation → Later start and complete deconsignation when work is finished.
5. The system generates notifications for relevant stakeholders at each step of the process.

### Managing Notifications
1. Navigate to the Notifications screen from the app drawer.
2. View all notifications with their read/unread status.
3. Tap on a notification to mark it as read and navigate to the related note if applicable.
4. Use the "Mark All as Read" button to clear all unread notifications.

### Viewing Admin Dashboard
1. Login as Admin.
2. Navigate to the Admin Dashboard screen from the app drawer.
3. View the Overview tab for general statistics and status distribution.
4. Check the Monthly Trends tab to see note creation and validation patterns over time.
5. Review the User Performance tab to monitor user activity and identify bottlenecks.

## License
Apache 2.0 License. See LICENSE.
