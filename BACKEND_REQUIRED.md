# 🚨 Backend Endpoint Required - Create Position

## ❌ Masalah Saat Ini

Aplikasi Flutter sudah siap untuk create position, tetapi **semua endpoint backend mengembalikan 404**:

```
❌ POST /positions → 404 Not Found
❌ POST /position → 404 Not Found  
❌ POST /hrd/positions → 404 Not Found
❌ POST /hrd/position/create → 404 Not Found
```

## ✅ Yang Dibutuhkan dari Backend

### Endpoint: `POST /positions`

**URL:** `https://learn.smktelkom-mlg.sch.id/jobsheeker/positions`

**Authentication:** Bearer Token (JWT)

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2
```

**Request Body:**
```json
{
  "position_name": "IT Support",
  "capacity": 2,
  "description": "pekerjaan ini membutuhkan skill tinggi",
  "submission_start_date": "2025-10-29 12:00:00",
  "submission_end_date": "2025-10-30 12:00:00"
}
```

**Expected Response (Success - 201):**
```json
{
  "success": true,
  "message": "Position created successfully",
  "data": {
    "id": 123,
    "uuid": "abc-def-ghi-jkl",
    "position_name": "IT Support",
    "capacity": 2,
    "description": "pekerjaan ini membutuhkan skill tinggi",
    "submission_start_date": "2025-10-29T12:00:00.000Z",
    "submission_end_date": "2025-10-30T12:00:00.000Z",
    "company_id": "company-uuid-from-token",
    "status": "active",
    "createdAt": "2025-10-29T08:20:00.000Z",
    "updatedAt": "2025-10-29T08:20:00.000Z"
  }
}
```

**Expected Response (Error - 400):**
```json
{
  "success": false,
  "message": "Validation error: position_name is required"
}
```

**Expected Response (Unauthorized - 401):**
```json
{
  "success": false,
  "message": "Unauthorized: Invalid or expired token"
}
```

## 💻 Contoh Implementasi Backend

### Node.js + Express + Sequelize

```javascript
const express = require('express');
const router = express.Router();
const { Position } = require('../models');
const { authenticateToken } = require('../middleware/auth');

// POST /positions - Create new position
router.post('/positions', authenticateToken, async (req, res) => {
  try {
    const { 
      position_name, 
      capacity, 
      description, 
      submission_start_date, 
      submission_end_date 
    } = req.body;

    // Validation
    if (!position_name || !capacity || !description || 
        !submission_start_date || !submission_end_date) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }

    // Get company_id from JWT token
    const company_id = req.user.company_id; // or however you store it in JWT
    
    if (!company_id) {
      return res.status(400).json({
        success: false,
        message: 'Company ID not found in token'
      });
    }

    // Create position
    const position = await Position.create({
      uuid: require('uuid').v4(), // Generate UUID
      position_name,
      capacity: parseInt(capacity),
      description,
      submission_start_date: new Date(submission_start_date),
      submission_end_date: new Date(submission_end_date),
      company_id,
      status: 'active',
    });

    return res.status(201).json({
      success: true,
      message: 'Position created successfully',
      data: position
    });

  } catch (error) {
    console.error('Error creating position:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Internal server error'
    });
  }
});

module.exports = router;
```

### Database Schema (Sequelize Model)

```javascript
module.exports = (sequelize, DataTypes) => {
  const Position = sequelize.define('Position', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    uuid: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      unique: true
    },
    position_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    capacity: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    submission_start_date: {
      type: DataTypes.DATE,
      allowNull: false
    },
    submission_end_date: {
      type: DataTypes.DATE,
      allowNull: false
    },
    company_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Companies',
        key: 'uuid'
      }
    },
    status: {
      type: DataTypes.ENUM('active', 'inactive', 'closed'),
      defaultValue: 'active'
    }
  }, {
    tableName: 'positions',
    timestamps: true
  });

  Position.associate = (models) => {
    Position.belongsTo(models.Company, {
      foreignKey: 'company_id',
      targetKey: 'uuid'
    });
  };

  return Position;
};
```

## 🧪 Testing dengan Postman

### Request
```
POST https://learn.smktelkom-mlg.sch.id/jobsheeker/positions

Headers:
  Content-Type: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  APP-KEY: d11869cbb24234949e1d47e131adbd7c6fc6d6b2

Body (raw JSON):
{
  "position_name": "IT Support",
  "capacity": 2,
  "description": "pekerjaan ini membutuhkan skill tinggi",
  "submission_start_date": "2025-10-29 12:00:00",
  "submission_end_date": "2025-10-30 12:00:00"
}
```

### Expected Success Response
```json
{
  "success": true,
  "message": "Position created successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "position_name": "IT Support",
    "capacity": 2,
    "description": "pekerjaan ini membutuhkan skill tinggi",
    "submission_start_date": "2025-10-29T12:00:00.000Z",
    "submission_end_date": "2025-10-30T12:00:00.000Z",
    "company_id": "f105d87b-8a94-4db4-8b42-46ea6e2aa7aa",
    "status": "active",
    "createdAt": "2025-10-29T08:20:00.000Z",
    "updatedAt": "2025-10-29T08:20:00.000Z"
  }
}
```

## ✅ Validation Rules

1. **position_name** (required, string, max 255)
2. **capacity** (required, integer, min 1)
3. **description** (required, text)
4. **submission_start_date** (required, datetime, format: "YYYY-MM-DD HH:MM:SS")
5. **submission_end_date** (required, datetime, must be >= submission_start_date)
6. **company_id** (auto from JWT token)

## 🔐 Security

- Endpoint harus protected dengan JWT authentication
- Company ID harus diambil dari token, bukan dari request body
- Validate bahwa user yang login adalah HRD
- Validate bahwa company_id di token valid

## 📝 Additional Endpoints (Optional)

### GET /positions - Get all positions for company
```javascript
router.get('/positions', authenticateToken, async (req, res) => {
  const company_id = req.user.company_id;
  const positions = await Position.findAll({ 
    where: { company_id },
    order: [['createdAt', 'DESC']]
  });
  res.json({ success: true, data: positions });
});
```

### GET /positions/:uuid - Get single position
```javascript
router.get('/positions/:uuid', authenticateToken, async (req, res) => {
  const position = await Position.findOne({ 
    where: { uuid: req.params.uuid }
  });
  if (!position) {
    return res.status(404).json({ 
      success: false, 
      message: 'Position not found' 
    });
  }
  res.json({ success: true, data: position });
});
```

### PUT /positions/:uuid - Update position
### DELETE /positions/:uuid - Delete position

## 🚀 Priority

**HIGH PRIORITY** - Aplikasi Flutter sudah siap dan menunggu endpoint ini.

## 📞 Contact

Jika ada pertanyaan tentang implementasi, silakan hubungi Flutter developer.

## ✅ Checklist untuk Backend Developer

- [ ] Create `positions` table in database
- [ ] Create Position model
- [ ] Implement POST /positions endpoint
- [ ] Add JWT authentication middleware
- [ ] Extract company_id from token
- [ ] Validate all required fields
- [ ] Test with Postman
- [ ] Deploy to server
- [ ] Notify Flutter developer when ready
