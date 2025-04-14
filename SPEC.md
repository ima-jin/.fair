# .fair Specification v0.2

## Fields

- `id`: Unique identifier (URI recommended)
- `title`: Short, descriptive title
- `context`: Domain or general context of contribution
- `contributors`: Array of contributor objects:
  - `actor`: contributor identity (direct or reference)
  - `role`: contributor's role (open-ended)
  - `weight`: numeric (optional) contribution weight
  - `meta`: optional metadata about the contribution
  - `temporal_splits`: array of time-based split configurations (optional)
- `metadata`: Additional contextual information (optional)
- `created_by`: Identifier for manifest creator
- `created_at`: ISO timestamp
- `updated_at`: ISO timestamp for last modification (optional)
- `tags`: array of relevant tags

## Temporal Splits

Temporal splits allow for contribution weights to change over time or based on conditions:

- `version`: Sequential version number for the split configuration
- `effective_from`: ISO timestamp when this split becomes active
- `effective_until`: ISO timestamp when this split expires (optional)
- `conditions`: Array of triggering conditions (e.g., "pre-recoup", "post-recoup")
- `description`: Human-readable explanation of the split
- `weight`: The contributor's weight under this configuration

### Selection Algorithm

When determining which split configuration applies at a specific point in time:

1. Filter splits by date range (current time must be between `effective_from` and `effective_until`)
2. Filter by applicable conditions (all conditions must be satisfied)
3. Select the highest version number among remaining splits
4. If no splits match, fall back to the contributor's base `weight` value

### Condition Types

Conditions can be categorized into several types:

1. **Time-based conditions** - Determined by calendar dates
   - Examples: `early-bird`, `standard-sales`

2. **State-based conditions** - Determined by the state of a project/entity
   - Examples: `pre-recoup`, `post-recoup`, `pre-release`, `post-release`

3. **Threshold conditions** - Determined by crossing numerical thresholds
   - Examples: `tickets-under-500`, `tickets-over-1000`

4. **Role-based conditions** - Applicable to specific contributor roles
   - Examples: `founder-vesting`, `investor-allocation`

### Common Condition Patterns

#### Music Industry Recoupment

- `pre-recoup`: Applied before recouping specified costs
- `post-recoup`: Applied after recouping specified costs

#### Software Vesting Schedules

- Time-based vesting without explicit conditions, using `effective_from` and `effective_until` dates
- Conditions may specify cliff periods or milestones (e.g., `after-cliff`, `after-milestone-1`)

#### Event Milestone Thresholds

- Time period conditions: `early-bird`, `standard-sales`
- Ticket threshold conditions: `tickets-under-500`, `tickets-over-500`
- Combined conditions: Both time period and threshold must be met

## Metadata

The `metadata` object contains context-specific information that helps interpret temporal splits.

### Common Metadata Patterns

#### Recoupment Metadata (Music)

```json
"metadata": {
  "recoup_threshold": {
    "amount": 5000,
    "currency": "USD",
    "description": "Production costs to be recouped before split changes"
  },
  "default_condition": "pre-recoup"
}
```

#### Vesting Schedule Metadata (Software)

```json
"metadata": {
  "vesting_schedule": {
    "type": "4-year with 1-year cliff",
    "start_date": "2025-01-01T00:00:00Z",
    "cliff_date": "2026-01-01T00:00:00Z",
    "full_vesting_date": "2029-01-01T00:00:00Z",
    "vesting_increments": "quarterly after cliff"
  },
  "total_equity": "100%"
}
```

#### Event Milestone Metadata (Events)

```json
"metadata": {
  "event_date": "2025-08-15T18:00:00Z",
  "ticket_sales_periods": {
    "early_bird": {
      "start": "2025-01-01T00:00:00Z",
      "end": "2025-05-31T23:59:59Z"
    },
    "standard": {
      "start": "2025-06-01T00:00:00Z",
      "end": "2025-08-14T23:59:59Z"
    }
  },
  "ticket_thresholds": [
    {"name": "tickets-under-500", "condition": "< 500"},
    {"name": "tickets-over-500", "condition": ">= 500"}
  ]
}
```

## Implementation Considerations

When implementing temporal splits:

1. **Validation**: Ensure split weights for a given timestamp/condition sum to 1.0 (or less if intentional)
2. **Backward Compatibility**: Implementations should support both traditional static weights and temporal splits
3. **Condition Resolution**: Implement a clear algorithm for determining which conditions are active
4. **Default Behavior**: Define fallback behavior when no splits match current conditions
