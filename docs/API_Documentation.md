# Ahara – API Documentation

**Version:** v1.0  
**Base URL:** `/api`  
**Authentication:** Firebase JWT (Bearer Token)  
**Content-Type:** `application/json`

---

## Authentication & Authorization

All protected routes require:

```
Authorization: Bearer <Firebase_ID_Token>
```

Role-Based Access Control (RBAC):

| Role       | Access Scope |
|------------|-------------|
| Buyer      | Browse, purchase, impact view |
| Seller     | Create listings, manage surplus |
| Volunteer  | Pickup coordination |
| Admin      | Verification, audits, reports |

---

# Standard API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message"
}
```

---

# Identity & User Management

## POST `/api/users/create`
Create or sync user from Firebase.

### Request Body
```json
{
  "firebaseUid": "string",
  "email": "string",
  "name": "string",
  "role": "buyer | seller | volunteer",
  "phone": "string",
  "location": "string"
}
```

---

## GET `/api/users/me`
Fetch logged-in user profile.

---

## PUT `/api/users/roles`
Update user roles (Admin only).

---

## POST `/api/users/report`
Report suspicious user behavior.

```json
{
  "reportedUserId": "string",
  "reason": "string",
  "description": "string"
}
```

---

# Trust & Verification APIs

## GET `/api/trust/:userId`
Fetch trust score of a user.

---

## PUT `/api/trust/update`
Update trust score after transaction.

---

## GET `/api/verification/:userId`
Get verification level.

---

## PUT `/api/verification/:userId`
Update verification status (Admin only).

---

# Consent & Audit APIs

## POST `/api/consent`
Record explicit transaction consent.

```json
{
  "userId": "string",
  "transactionId": "string",
  "consentHash": "string",
  "timestamp": "ISO date"
}
```

---

## GET `/api/consent/:userId`
Fetch consent history.

---

## GET `/api/audit/logs`
Retrieve audit logs (Admin only).

---

# Surplus Listing APIs

## POST `/api/listings`
Create surplus food listing.

```json
{
  "title": "Cooked Rice",
  "foodType": "Cooked",
  "quantity": 25,
  "price": 50,
  "storageMethod": "Refrigerated",
  "expiryTime": "ISO date"
}
```

---

## GET `/api/listings`
Query parameters:
```
?location=Coimbatore
?radius=10
?sort=expiry
```

---

## GET `/api/listings/:id`
View listing details.

---

## PUT `/api/listings/:id`
Update listing.

---

## DELETE `/api/listings/:id`
Delete listing.

---

## GET `/api/listings/:id/state`
Returns listing lifecycle state:
- Available  
- Reserved  
- Expired  
- PickedUp  

---

# Safety & Hygiene APIs

## POST `/api/hygiene`
Submit hygiene declaration.

```json
{
  "listingId": "string",
  "cleanKitchen": true,
  "temperatureControlled": true,
  "documents": ["url1"]
}
```

---

## POST `/api/safety/validate`
Validate listing against safety rules.

---

## GET `/api/safety/status/:listingId`
Get safety compliance status.

---

# Matching & Pickup Coordination APIs

## POST `/api/match`
Match buyer with nearby listings.

```json
{
  "buyerId": "string",
  "location": "string"
}
```

---

## POST `/api/pickup/assign`
Assign volunteer for pickup.

```json
{
  "listingId": "string",
  "volunteerId": "string"
}
```

---

## PUT `/api/pickup/status`
Update pickup status.

```json
{
  "pickupId": "string",
  "status": "Assigned | InTransit | Delivered | Failed"
}
```

---

## POST `/api/pickup/escalate`
Trigger re-matching workflow on failure.

---

# Route Optimization APIs

## GET `/api/routes/:pickupId`
Returns optimized pickup route with time constraints.

---

# Impact & Analytics APIs

## GET `/api/impact/:transactionId`
Returns environmental impact data.

```json
{
  "mealsSaved": 15,
  "co2ReducedKg": 4.2
}
```

---

## GET `/api/impact/summary`
Platform-wide impact metrics.

---

## GET `/api/dashboard/admin`
Admin analytics dashboard.

---

# Pricing & Incentives APIs

## GET `/api/pricing/rules`
Get surplus pricing boundaries.

---

## GET `/api/reputation/:userId`
Fetch user reputation score.

---

## GET `/api/badges/:userId`
Retrieve earned badges.

---

# Language & Accessibility APIs

## PUT `/api/preferences/language`
Update language preference.

```json
{
  "language": "en | ta | hi"
}
```

---

## GET `/api/preferences/:userId`
Fetch user preferences.

---

# Notifications APIs

## GET `/api/notifications`
Retrieve user notifications.

---

## POST `/api/notifications/read`
Mark notification as read.

---

# HTTP Status Codes

| Code | Meaning |
|------|----------|
| 200  | Success |
| 201  | Created |
| 400  | Bad Request |
| 401  | Unauthorized |
| 403  | Forbidden |
| 404  | Not Found |
| 409  | Conflict |
| 500  | Server Error |

---

# Security Notes

- Firebase JWT verification middleware required  
- Role-based access control enforced per route  
- Rate limiting recommended  
- Consent logs stored immutably  
- Duplicate user protection enabled  
- Safety validation required before purchase  

---

# Future Enhancements

- API Versioning (`/api/v2`)
- GraphQL Gateway
- Event-driven audit logging
- WebSocket live pickup tracking
- Microservice decomposition

---

# Coverage Summary

✔ Identity & Roles  
✔ Trust & Verification  
✔ Consent & Audit  
✔ Surplus Listings  
✔ Safety & Hygiene  
✔ Matching & Pickup  
✔ Route Optimization  
✔ Impact & Analytics  
✔ Pricing & Incentives  
✔ Multilingual & Accessibility  
✔ Notifications  
✔ Admin Controls  

---

**Ahara – Enabling Safe, Transparent & Impact-Driven Surplus Food Redistribution**
