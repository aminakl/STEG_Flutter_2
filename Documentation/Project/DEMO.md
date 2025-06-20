# STEG LOTO Application Demo Guide

## Introduction

This document provides a step-by-step guide to demonstrate the enhanced consignation process in the STEG LOTO application. The workflow now includes maneuver sheets, consignation steps, EPI verification, and work attestations.

## User Roles and Permissions

The application supports the following roles with specific permissions:

1. **ADMIN**: Full access to all features
2. **CHEF_EXPLOITATION**: Creates notes and submits them for validation
3. **CHEF_DE_BASE**: Validates notes submitted by Chef d'exploitation
4. **CHARGE_EXPLOITATION**: Assigns validated notes to Chargé de consignation
5. **CHARGE_CONSIGNATION**: Performs consignation/deconsignation and issues work attestations
6. **CHARGE_TRAVAUX**: Performs work with attestations

## Complete Workflow Demonstration

### 1. Note Creation (CHEF_EXPLOITATION)

1. Log in as a user with CHEF_EXPLOITATION role
2. Navigate to the Notes dashboard
3. Click "Create New Note"
4. Fill in the required fields:
   - Unité STEG
   - Poste HT
   - Poste Récepteur (optional)
   - **Equipment Type** (select from LIGNE_HT, TRANSFORMATEUR, or COUPLAGE)
   - Work Description
   - Equipment Details
   - Planning dates (retrait, travaux début/fin, retour)
   - Technical Instructions
5. Click "Submit for Validation"
6. The note status changes to PENDING_CHEF_BASE

### 2. Note Validation by Chef de Base (CHEF_DE_BASE)

1. Log in as a user with CHEF_DE_BASE role
2. Navigate to the Notes dashboard
3. Filter notes by status "Pending Chef Base"
4. Select a note to review
5. Review the note details
6. Click either:
   - "Validate" to approve the note (status changes to PENDING_CHARGE_EXPLOITATION)
   - "Reject" to reject the note (provide rejection reason, status changes to REJECTED)

### 3. Note Assignment by Chargé d'Exploitation (CHARGE_EXPLOITATION)

1. Log in as a user with CHARGE_EXPLOITATION role
2. Navigate to the Notes dashboard
3. Filter notes by status "Pending Charge Exploitation"
4. Select a note to review
5. Review the note details
6. Click "Assign" and select a Chargé de Consignation from the dropdown
7. The note status changes to VALIDATED and is assigned to the selected user

### 4. Maneuver Sheet Creation (CHARGE_CONSIGNATION)

1. Log in as a user with CHARGE_CONSIGNATION role
2. Navigate to the Notes dashboard
3. Filter notes by status "Validated" and assigned to you
4. Select a note to view details
5. Navigate to the "Maneuver Sheets" tab
6. Click "Create Maneuver Sheet"
7. The system automatically creates a maneuver sheet based on the equipment type
8. The maneuver sheet includes:
   - Electrical schema for the equipment type
   - Predefined consignation steps
   - EPI verification checklist

### 5. EPI Verification (CHARGE_CONSIGNATION)

1. Navigate to the "EPI Verification" tab on the maneuver sheet
2. Verify each required personal protective equipment:
   - Casque Isolant
   - Gants Isolants
   - Écran Facial
   - Vêtements Ignifuges
   - Chaussures Diélectriques
3. All items must be verified before proceeding with consignation

### 6. Consignation Process (CHARGE_CONSIGNATION)

1. Navigate to the "Consignation Steps" tab
2. Click "Start Consignation" (only enabled if EPI verification is complete)
3. The system records the consignation start time
4. Complete each step in sequence:
   - Each step shows equipment designation, operation, and rep number
   - Click "Complete" for each step
   - The system records the completion time and duration
5. After all steps are completed, click "Complete Consignation"
6. The system records the consignation completion time

### 7. Schema Modification (CHARGE_CONSIGNATION)

1. Navigate to the "Electrical Schema" tab
2. The system displays the original schema based on the equipment type
3. Use the element toolbar to select what to add:
   - **GND (Ground)**: Adds grounding points to the schema
   - **INTERRUPTEUR (Switch)**: Adds switch symbols to the schema
4. Once an element is selected:
   - Click anywhere on the schema to place the element
   - Drag to reposition elements
   - Use the rotation control to adjust orientation
   - Elements can be deleted by selecting and pressing the delete button
5. Each modification is recorded in the database with position coordinates
6. Click "Save Modifications" to finalize changes
7. The system generates a modified schema image that will be included in the PDF
8. All modifications can be viewed in the history panel showing who made each change

### 8. Work Attestation Issuance (CHARGE_CONSIGNATION)

1. Navigate to the "Work Attestations" tab
2. Click "Create Work Attestation"
3. Select a Chargé de Travaux from the dropdown
4. The system generates a unique attestation number
5. The attestation is valid for 24 hours by default
6. Click "Generate PDF" to create a printable attestation

### 9. Work Execution (CHARGE_TRAVAUX)

1. Log in as a user with CHARGE_TRAVAUX role
2. Navigate to the "My Attestations" dashboard
3. View active attestations assigned to you
4. Click on an attestation to view details
5. Perform the work according to the instructions

### 10. Deconsignation Process (CHARGE_CONSIGNATION)

1. Log in as a user with CHARGE_CONSIGNATION role
2. Navigate to the Notes dashboard
3. Select a note with completed consignation
4. Navigate to the "Maneuver Sheets" tab
5. Select the maneuver sheet
6. Click "Start Deconsignation"
7. Complete each deconsignation step in sequence
8. After all steps are completed, click "Complete Deconsignation"
9. The note status is updated to indicate completed deconsignation

## Key Features Demonstrated

1. **Equipment Type Selection**: Visual selection of equipment type during note creation
2. **Maneuver Sheet Management**: Automatic generation of maneuver sheets based on equipment type
3. **Consignation Steps**: Step-by-step tracking of consignation and deconsignation procedures
4. **EPI Verification**: Checklist for personal protective equipment verification
5. **Schema Modification**: Interactive canvas for modifying electrical schemas
6. **Work Attestations**: Generation and management of work attestations
7. **Real-time Progress Tracking**: Dashboard showing consignation progress and status
8. **Role-based Access Control**: Different views and permissions based on user roles

## Troubleshooting

- If a step cannot be completed, ensure that all prerequisites are met
- If EPI verification cannot be completed, ensure all items are checked
- If work attestation cannot be created, ensure consignation is complete
- If deconsignation cannot be started, ensure all work attestations are revoked or expired
