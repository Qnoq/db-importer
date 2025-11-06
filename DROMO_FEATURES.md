# Dromo-Inspired Features 🎯

This document describes the advanced features added to DB-Importer, inspired by Dromo's data import tool.

## Overview

Four major feature sets have been implemented to bring DB-Importer closer to enterprise-grade tools like Dromo:

1. **Data Transformations**
2. **Mapping Templates**
3. **Smart Data Validation with Highlighting**
4. **Intelligent Date Parsing**

---

## 1. Data Transformations 🔄

### Location
`frontend/src/utils/transformations.ts`

### Features

**13 Built-in Transformations:**
- `uppercase` - Convert to UPPERCASE
- `lowercase` - Convert to lowercase
- `trim` - Remove leading/trailing spaces
- `capitalize` - Capitalize Each Word
- `removeSpaces` - Removeallspaces
- `removeSpecialChars` - Keep only alphanumeric
- `formatPhone` - Extract digits from phone numbers
- `formatEmail` - Normalize email addresses
- `extractNumbers` - Extract only numeric characters
- `toBoolean` - Convert yes/no/1/0 to boolean
- `toNumber` - Parse numeric values
- `formatDate` - Parse and format dates
- `none` - No transformation

**Smart Suggestion System:**
- Analyzes column data to suggest appropriate transformations
- Type-aware suggestions based on SQL field type
- Pattern matching for emails, phones, names

**Preview Capability:**
- Real-time preview of transformations
- See before/after for first 10 rows
- Helps users understand transformation impact

### Usage Example

```typescript
// Apply transformation
const result = applyTransformation("John  Doe  ", "trim")
// Result: "John  Doe"

// Get suggestions for a column
const suggestions = suggestTransformations(columnData, "varchar(100)")
// Returns: ['none', 'trim', 'capitalize', 'formatEmail']
```

### UI Integration

In the Mapping page:
1. Select column mapping
2. Choose transformation from dropdown
3. Click "Preview" to see transformation results
4. Transformations are automatically applied before SQL generation

---

## 2. Mapping Templates 💾

### Location
`frontend/src/utils/mappingTemplates.ts`

### Features

**Template Management:**
- Save column mappings as reusable templates
- Store transformations with templates
- Template CRUD operations (Create, Read, Update, Delete)
- LocalStorage persistence with versioning

**Template Search:**
- Filter templates by table name
- Search by template name or description
- Similarity matching (suggests templates based on current mapping)

**Import/Export:**
- Export all templates as JSON
- Import templates from JSON file
- Validation and duplicate detection on import

**Template Structure:**
```typescript
{
  id: "template_1234567890_abc123",
  name: "Customer Import",
  description: "Standard customer data import",
  tableName: "customers",
  mapping: {
    "Email": "email",
    "Full Name": "name",
    "Phone": "phone_number"
  },
  transformations: {
    "Email": "formatEmail",
    "Full Name": "capitalize",
    "Phone": "formatPhone"
  },
  createdAt: "2024-01-01T00:00:00.000Z",
  updatedAt: "2024-01-01T00:00:00.000Z"
}
```

### UI Features

**Template Dialog:**
- Click "Templates" button in header
- View all saved templates
- Apply template with one click
- Delete unwanted templates

**Save Template:**
- Click "Save as Template" button
- Enter template name and description
- Saves current mapping + transformations

**Export/Import:**
- "Export All" button downloads JSON file
- "Import" button accepts JSON file
- Validation ensures data integrity

---

## 3. Smart Data Validation with Highlighting 🎨

### Location
`frontend/src/utils/dataValidation.ts`

### Features

**Comprehensive Validation:**

**Type Validation:**
- Numeric: Range checks for TINYINT, SMALLINT, etc.
- Boolean: Validates true/false/1/0/yes/no
- Date/Time: Parses and validates date formats
- String: Length validation for VARCHAR/CHAR

**Constraint Validation:**
- NOT NULL constraints
- Precision/scale for DECIMAL types
- Integer vs float detection

**Special Validations:**
- Email format detection
- URL format detection
- Phone number patterns
- Unusual values (e.g., year < 1900 or > 2100)

**Severity Levels:**
- **Error** (red): Data will fail insertion
- **Warning** (yellow): Data might be truncated/modified
- **Info** (blue): Informational messages
- **Success** (green): Valid data

### Validation Results

Each cell gets a validation result:
```typescript
{
  valid: false,
  severity: 'error',
  message: 'Expected number, got "abc"',
  suggestion: 'Provide a valid numeric value',
  rowIndex: 5,
  columnIndex: 2,
  fieldName: 'age'
}
```

### UI Features

**Real-time Validation:**
- Validates on mapping change
- Validates on transformation change
- Shows stats in header banner

**Preview with Highlighting:**
- Color-coded cells based on validation
- Hover to see error message
- Icons indicate validation status

**Validation Stats:**
```
✓ 95 valid  ⚠ 3 warnings  ✗ 2 errors
```

**Color Scheme:**
- 🔴 Red background: Errors
- 🟡 Yellow background: Warnings
- 🔵 Blue background: Info
- 🟢 Green background: Success

---

## 4. Intelligent Date Parsing 📅

### Location
`frontend/src/utils/transformations.ts` (parseSmartDate function)

### Features

**Multiple Format Support:**
- ISO: `2024-01-15`, `2024-01-15T12:30:00`
- US: `01/15/2024`, `1/15/2024`
- EU: `15/01/2024`
- Dash: `15-01-2024`
- Natural: `January 15, 2024`

**Smart Detection:**
- Tries multiple formats automatically
- Handles both EU and US date formats
- Falls back to JavaScript Date.parse()
- Returns null for unparseable dates

**Normalization:**
- All dates normalized to `YYYY-MM-DD`
- Consistent output format for database
- Handles single-digit days/months

### Usage Example

```typescript
parseSmartDate("15/01/2024")  // Returns: Date(2024-01-15)
parseSmartDate("1-15-2024")   // Returns: Date(2024-01-15)
parseSmartDate("2024-01-15")  // Returns: Date(2024-01-15)
parseSmartDate("invalid")     // Returns: null
```

**Integration:**
- Available as `formatDate` transformation
- Automatically suggested for DATE/DATETIME fields
- Preview shows parsed result

---

## Enhanced Mapping UI 🎨

### New Features

**Multi-column Layout:**
```
Excel Column    | DB Column      | Transformation | Status
Email           | email          | formatEmail    | ✓ Mapped + Preview button
Full Name       | name           | capitalize     | ✓ Mapped + Preview button
Phone Number    | phone_number   | formatPhone    | ✓ Mapped + Preview button
```

**Validation Stats Banner:**
```
Target table: customers | Data rows: 100
✓ 95 valid  ⚠ 3 warnings  ✗ 2 errors
```

**Action Buttons:**
- 🟢 Generate & Download SQL
- 🔵 Auto-map
- ⚪ Show/Hide Preview
- 🟣 Validate Data
- 🟤 Save as Template
- 🟣 Templates

**Dialog Modals:**
- Template Selection Dialog
- Save Template Dialog
- Transformation Preview Dialog

---

## Performance Optimizations ⚡

**Efficient Validation:**
- Validates only first 20 rows for preview
- Full validation on demand
- Caches validation results

**LocalStorage:**
- Templates stored locally
- No server requests needed
- Fast template loading

**Smart Suggestions:**
- Analyzes only first 10 rows for transformation suggestions
- Caches column data analysis
- Lazy loading of transformations

---

## Comparison with Dromo

| Feature | Dromo | DB-Importer | Notes |
|---------|-------|-------------|-------|
| AI-powered mapping | ✅ GPT | ✅ Levenshtein | We use algorithmic approach |
| Transformations | ✅ AI + presets | ✅ 13 presets | Smart suggestions by type |
| Templates | ✅ Cloud | ✅ Local | LocalStorage-based |
| Validation | ✅ Real-time | ✅ Real-time | Comprehensive type checking |
| Preview | ✅ Workbook | ✅ Table | Highlighted cells |
| Error highlighting | ✅ | ✅ | Color-coded with icons |
| Date parsing | ✅ | ✅ | Multi-format support |
| Bulk edit | ✅ AI | ❌ | Future feature |
| Export templates | ✅ | ✅ | JSON format |
| Import templates | ✅ | ✅ | JSON format |
| Self-hosted | ❌ | ✅ | Major advantage |
| Open source | ❌ | ✅ | Free forever |
| No data to 3rd party | ❌ | ✅ | Privacy-first |

---

## Usage Workflow

### Typical Import Session

1. **Upload Schema** (.sql file)
2. **Select Table** (customers)
3. **Upload Data** (customers.csv)
4. **Map Columns:**
   - Auto-map runs automatically
   - Review mappings
   - Adjust if needed
5. **Apply Transformations:**
   - Check suggested transformations
   - Preview transformations
   - Modify if needed
6. **Validate:**
   - Click "Validate Data"
   - Review errors/warnings
   - Fix data if needed
7. **Save Template** (optional):
   - Click "Save as Template"
   - Name it "Customer Import"
   - Reuse next time
8. **Generate SQL:**
   - All transformations applied
   - All validations passed
   - Download .sql file
9. **Execute SQL** (in your database)

### Next Import (with Template)

1. Upload Schema
2. Select Table
3. Upload Data
4. **Click "Templates"**
5. **Select "Customer Import"**
6. Mappings + transformations applied
7. Generate SQL
8. Done! ⚡

---

## Code Organization

```
frontend/src/
├── utils/
│   ├── transformations.ts       # 13 transformations + smart suggestions
│   ├── mappingTemplates.ts      # Template CRUD + import/export
│   └── dataValidation.ts        # Validation engine + highlighting
│
└── pages/
    └── Mapping.vue              # Enhanced UI with all features
```

**Lines of Code:**
- transformations.ts: ~370 lines
- mappingTemplates.ts: ~280 lines
- dataValidation.ts: ~380 lines
- Mapping.vue: ~960 lines (from 344)

**Total:** ~2000 lines of new code

---

## Future Enhancements

**Planned Features:**
- [ ] Custom transformation functions (user-defined)
- [ ] Bulk edit with regex
- [ ] Column statistics (min/max/avg/unique count)
- [ ] Duplicate detection
- [ ] Data profiling dashboard
- [ ] Undo/Redo for mappings
- [ ] Keyboard shortcuts
- [ ] Dark mode for preview
- [ ] AI-powered suggestions (OpenAI integration)

**Community Requests:**
- [ ] CSV encoding auto-detection
- [ ] Multi-sheet Excel support
- [ ] Column splitting/merging
- [ ] Conditional transformations
- [ ] Macro recording

---

## Credits

Inspired by:
- **Dromo** (dromo.io) - Enterprise data import tool
- **Flatfile** - CSV import platform
- **OneSchema** - Data import solution

Built with ❤️ for the open-source community.

---

## License

MIT - Same as main project

---

**Ready to import data like a pro? Try the new features now! 🚀**
