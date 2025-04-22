# `.fair` – Attribution & Compensation Manifests

A simple, flexible system for tracking attribution and compensation in creative works. `.fair` provides a standardized way to document who contributed to a creative asset and how value should be distributed.

## 🌟 Purpose

`.fair` manifests serve as a single source of truth for:

- Revenue and royalty splitting
- Creative attribution
- Contributor provenance
- Transparent audits and social accountability

## 🔧 Field Overview

Each `.fair.json` file must conform to the schema defined in `schema/fair.schema.json`.

### Required Fields

| Field          | Type     | Description                                                  |
| -------------- | -------- | ------------------------------------------------------------ |
| `id`           | `string` | Unique ID for this attribution manifest                      |
| `type`         | `string` | One of: `set`, `track`, `performance`, `event`, or `project` |
| `title`        | `string` | Human-readable title of the asset                            |
| `version`      | `string` | Schema version (e.g. `0.3.0`)                                |
| `contributors` | `array`  | Array of contributor records                                 |

### Contributor Object

| Field    | Type      | Description                                                                         |
| -------- | --------- | ----------------------------------------------------------------------------------- |
| `id`     | `string`  | Contributor's unique ID                                                             |
| `role`   | `string`  | One of: `artist`, `producer`, `engineer`, `writer`, `performer`, `curator`, `other` |
| `weight` | `number`  | Value share (0-1 range, must sum to 1)                                             |
| `notes`  | `string?` | Optional description of their contribution                                          |

## 🧹 Optional Fields

### `context`

Use this to describe how the `.fair.json` was generated or derived.

```json
{
  "source": "graphql" | "tinybird" | "manual",
  "sourceId": "unique-id",
  "derivedFrom": [
    {
      "type": "string",
      "id": "string",
      "timestamp": "ISO-8601"
    }
  ]
}
```

### `metadata`

Used to attach supplemental information about the asset.

```json
{
  "tags": ["string"],
  "description": "string",
  "duration": number,
  "location": "string",
  "date": "ISO-8601",
  "custom": {}
}
```

## 🪪 Validation

Use the schema validator to ensure your `.fair.json` files are valid:

```bash
npm install -g ajv-cli
ajv validate -s schema/fair.schema.json -d your-file.fair.json
```

## 🛠️ Creating a `.fair.json`

1. Identify the creative asset and its contributors
2. Determine contributor roles and weights
3. Fill out the required fields
4. Optionally include `context` and `metadata`
5. Save the file using the naming convention below

## 💼 Naming Convention

File naming format:

```
<type>_<context>_<primary>.fair.json
```

Where:

- `type` = asset type (`set`, `track`, `event`, etc.)
- `context` = event name or slug (e.g. `skyland2025`)
- `primary` = lead contributor or focal creator

**Example:**

```
set_skyland2025_sethschwarz.fair.json
```

## 🤖 Integration

`.fair.json` files can be integrated into various systems:

- Embedded in track metadata
- Used in payout engines
- Integrated with content management systems
- Used for attribution displays

## 🔗 Related Files

- `schema/fair.schema.json` – JSON Schema definition
- `SPEC.md` – Detailed specification
- `examples/` – Example manifests

## 📦 Installation

```bash
npm install @imajin/fair
```

## 📝 License

MIT License - See LICENSE file for details
