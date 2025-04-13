# .fair Specification v0.1

## Fields

- `id`: Unique identifier (URI recommended)
- `title`: Short, descriptive title
- `context`: Domain or general context of contribution
- `contributors`: Array of contributor objects:
  - `actor`: contributor identity (direct or reference)
  - `role`: contributor's role (open-ended)
  - `weight`: numeric (optional) contribution weight
  - `meta`: optional metadata about the contribution
- `created_by`: Identifier for manifest creator
- `created_at`: ISO timestamp
- `tags`: array of relevant tags
