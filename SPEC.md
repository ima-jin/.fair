# .fair Specification v0.3

## Overview

`.fair` is a simple, flexible system for tracking attribution and compensation in creative works. It provides a standardized way to document who contributed to a creative asset and how value should be distributed.

## Core Fields

- `id`: Unique identifier (URI recommended)
- `type`: Type of creative asset (`set`, `track`, `performance`, `event`, `project`)
- `title`: Human-readable title of the asset
- `version`: Schema version (e.g. `0.3.0`)
- `contributors`: Array of contributor objects
- `createdAt`: ISO timestamp of creation (optional)
- `updatedAt`: ISO timestamp of last modification (optional)
- `context`: Optional context about how the manifest was generated
- `metadata`: Optional additional information about the asset

## Contributor Object

Each contributor object must contain:

- `id`: Unique identifier for the contributor
- `role`: One of: `artist`, `producer`, `engineer`, `writer`, `performer`, `curator`, `other`
- `weight`: Numeric value between 0 and 1 representing their share
- `notes`: Optional description of their contribution

## Context Object

The context object provides information about how the manifest was generated:

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

## Metadata Object

The metadata object can contain any additional information about the asset:

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

## Implementation Notes

1. **Validation**: 
   - All required fields must be present
   - Contributor weights should sum to 1.0 (or less if intentional)
   - IDs should be unique and stable
   - Timestamps should be in ISO-8601 format

2. **Usage**:
   - Manifests are typically stored as `.fair.json` files
   - Can be embedded in other systems (e.g., track metadata)
   - Used for both attribution and compensation calculations

3. **Versioning**:
   - Schema version should follow semantic versioning
   - Breaking changes should increment major version
   - New features should increment minor version
   - Bug fixes should increment patch version

## Example Usage

### Track Attribution

```json
{
  "id": "track-123",
  "type": "track",
  "title": "Summer Vibes",
  "version": "0.3.0",
  "contributors": [
    {
      "id": "artist-456",
      "role": "artist",
      "weight": 0.6,
      "notes": "Lead vocals and composition"
    },
    {
      "id": "producer-789",
      "role": "producer",
      "weight": 0.4,
      "notes": "Production and mixing"
    }
  ],
  "context": {
    "source": "graphql",
    "sourceId": "track-123"
  },
  "metadata": {
    "duration": 180,
    "genre": ["House", "Deep House"]
  }
}
```

### Event Attribution

```json
{
  "id": "event-xyz",
  "type": "event",
  "title": "Summer Festival 2024",
  "version": "0.3.0",
  "contributors": [
    {
      "id": "curator-123",
      "role": "curator",
      "weight": 0.3,
      "notes": "Event curation and programming"
    },
    {
      "id": "artist-456",
      "role": "artist",
      "weight": 0.4,
      "notes": "Headline performance"
    },
    {
      "id": "artist-789",
      "role": "artist",
      "weight": 0.3,
      "notes": "Support performance"
    }
  ],
  "metadata": {
    "location": "Beach Club, Ibiza",
    "date": "2024-07-15T20:00:00Z"
  }
}
```

## Service Layer Integration

`.fair` manifests can be integrated with various service layers and data pools to provide rich context and enable automated workflows.

### Music Industry Integration

#### Distribution Platforms

```json
{
  "context": {
    "source": "graphql",
    "sourceId": "track-123",
    "derivedFrom": [
      {
        "type": "distrokid",
        "id": "DK-123456",
        "timestamp": "2024-03-15T12:00:00Z"
      },
      {
        "type": "spotify",
        "id": "spotify:track:7xGfFoTpQ2E7fRF5lN10tr",
        "timestamp": "2024-03-16T00:00:00Z"
      }
    ]
  },
  "metadata": {
    "isrc": "US-ABC-12-34567",
    "upc": "123456789012",
    "releaseDate": "2024-03-15T00:00:00Z",
    "distributor": "DistroKid",
    "platforms": ["Spotify", "Apple Music", "Amazon Music"]
  }
}
```

#### Rights Management

```json
{
  "context": {
    "source": "manual",
    "sourceId": "rights-789",
    "derivedFrom": [
      {
        "type": "pro_ipi",
        "id": "IPI-123456789",
        "timestamp": "2024-02-01T00:00:00Z"
      },
      {
        "type": "publisher",
        "id": "PUB-987654321",
        "timestamp": "2024-02-01T00:00:00Z"
      }
    ]
  },
  "metadata": {
    "publishingRights": {
      "territories": ["Worldwide"],
      "duration": "Life + 70 years",
      "splits": {
        "writer": 0.5,
        "publisher": 0.5
      }
    }
  }
}
```

### Data Pool Integration

#### Context Data Pools

`.fair` manifests can reference and be enriched by various data pools:

1. **Music Metadata Pools**
   - ISRC databases
   - MusicBrainz
   - Discogs
   - Gracenote

2. **Rights Management Pools**
   - PRO databases (ASCAP, BMI, etc.)
   - Publishing rights databases
   - Mechanical rights databases

3. **Distribution Pools**
   - Digital service providers (DSPs)
   - Physical distribution networks
   - Performance rights organizations

#### Integration Patterns

1. **Direct Integration**
   ```json
   {
     "context": {
       "source": "musicbrainz",
       "sourceId": "mbid-123",
       "derivedFrom": [
         {
           "type": "isrc",
           "id": "US-ABC-12-34567",
           "timestamp": "2024-03-15T00:00:00Z"
         }
       ]
     }
   }
   ```

2. **Aggregated Integration**
   ```json
   {
     "context": {
       "source": "aggregator",
       "sourceId": "agg-123",
       "derivedFrom": [
         {
           "type": "multiple",
           "sources": [
             {"type": "spotify", "id": "spotify:track:7xGfFoTpQ2E7fRF5lN10tr"},
             {"type": "apple", "id": "123456789"},
             {"type": "amazon", "id": "B0ABCDEFGH"}
           ]
         }
       ]
     }
   }
   ```

### Service Layer Considerations

1. **Data Freshness**
   - Timestamps should be included for all external references
   - Consider implementing TTL (Time To Live) for cached data
   - Provide mechanisms for data refresh and validation

2. **Data Consistency**
   - Implement versioning for external data references
   - Handle conflicts between different data sources
   - Provide reconciliation mechanisms

3. **Security & Privacy**
   - Consider data access controls
   - Implement proper authentication for sensitive data
   - Follow data protection regulations (GDPR, CCPA, etc.)

4. **Performance**
   - Implement caching strategies
   - Consider batch processing for large datasets
   - Optimize data fetching patterns

### Example: Full Music Industry Integration

```json
{
  "id": "track-123",
  "type": "track",
  "title": "Summer Vibes",
  "version": "0.3.0",
  "contributors": [
    {
      "id": "artist-456",
      "role": "artist",
      "weight": 0.6,
      "notes": "Lead vocals and composition",
      "metadata": {
        "pro": "ASCAP",
        "ipi": "IPI-123456789",
        "isni": "0000000123456789"
      }
    },
    {
      "id": "producer-789",
      "role": "producer",
      "weight": 0.4,
      "notes": "Production and mixing",
      "metadata": {
        "pro": "BMI",
        "ipi": "IPI-987654321",
        "isni": "0000000987654321"
      }
    }
  ],
  "context": {
    "source": "graphql",
    "sourceId": "track-123",
    "derivedFrom": [
      {
        "type": "distrokid",
        "id": "DK-123456",
        "timestamp": "2024-03-15T12:00:00Z"
      },
      {
        "type": "musicbrainz",
        "id": "mbid-123",
        "timestamp": "2024-03-14T00:00:00Z"
      }
    ]
  },
  "metadata": {
    "isrc": "US-ABC-12-34567",
    "upc": "123456789012",
    "releaseDate": "2024-03-15T00:00:00Z",
    "distributor": "DistroKid",
    "platforms": ["Spotify", "Apple Music", "Amazon Music"],
    "publishingRights": {
      "territories": ["Worldwide"],
      "duration": "Life + 70 years"
    }
  }
}
```
