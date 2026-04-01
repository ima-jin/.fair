> **Changelog — 2026-03-23 (v0.4.0):** DFOS integration — Attribution now uses DFOS bilateral attestations (countersignatures); both parties must sign. Assets are content-addressed by CID backed by DFOS content chains. A `.fair` manifest creation is a content chain genesis event. Cross-graph deduplication operates via content hash across chains. Every marketplace transaction, tip, and enrollment produces a bilateral attestation as cryptographic proof of mutual agreement. Revocation tiers added: withdraw → soft revoke → hard revoke (via chain operations).

---

# .fair Specification v0.3 (with v0.2.0 and v0.4.0 extensions)

## Overview

`.fair` is a simple, flexible system for tracking attribution and compensation in creative works, code, and runtime services. It provides a standardized way to document who contributed to an asset and how value should be distributed.

In the JBOS architecture (see RFC-0001), `.fair` is a **kernel primitive** — part of the cryptographic layer that userspace services depend on, not a service that can be swapped out. Settlement won't process without a valid, countersigned `.fair` manifest. Attribution chains are anchored to content chains on the DFOS substrate. The kernel doesn't care which services exist above it, but it enforces `.fair` at the boundary: no manifest, no settlement.

**Version History:**
- **v0.4.0** (March 2026) — DFOS integration: bilateral attestations, CID-backed asset identity, content chain genesis, cross-graph dedup, revocation tiers
- **v0.3.0** (April 2025) — Schema refinements, temporal splits
- **v0.2.0** (March 2026) — Runtime modules, DID-based identity, settlement abstraction, trust graph integration
- **v0.1.0** (April 2025) — Initial release for creative content

## Core Fields

- `id`: Unique identifier (URI recommended)
- `type`: Type of creative asset (`set`, `track`, `performance`, `event`, `project`, `runtime-module`)
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
- `role`: One of: `artist`, `producer`, `engineer`, `writer`, `performer`, `curator`, `operator`, `protocol`, `other`
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

---

## v0.2.0 Extensions: Runtime Modules and Services

The following sections describe extensions introduced in v0.2.0 for runtime computational services.

### Runtime Module Manifests

Runtime modules (inference, memory, embedding, search) declare `.fair` manifests to enable transparent attribution across computational graphs.

#### Core Fields for Runtime Modules

In addition to standard `.fair` fields, runtime modules include:

- `type`: Set to `"runtime-module"`
- `capabilities`: Array of capability strings (e.g., `["text-generation", "chat"]`)
- `pricing`: Pricing model object
- `endpoint`: Optional service endpoint URI
- `did`: DID-based identity for the module operator

#### Pricing Model Object

```json
{
  "model": "metered" | "fixed" | "hybrid",
  "unit": "token" | "query" | "second" | "byte",
  "rate": number,
  "currency": "USD" | "MJN" | "SOL"
}
```

**Metered**: Pay-per-use based on consumption units (tokens, queries, etc.)
**Fixed**: Flat rate per time period or per session
**Hybrid**: Combination of base fee plus metered usage

#### Example: Inference Module

```json
{
  "id": "inference:gpt4:operator-alice",
  "type": "runtime-module",
  "title": "GPT-4 Inference Node",
  "version": "0.2.0",
  "capabilities": ["text-generation", "chat", "code-completion"],
  "pricing": {
    "model": "metered",
    "unit": "token",
    "rate": 0.00003,
    "currency": "USD"
  },
  "contributors": [
    {
      "id": "did:imajin:alice",
      "role": "operator",
      "weight": 0.7,
      "notes": "Node operator and infrastructure"
    },
    {
      "id": "mjn:protocol",
      "role": "protocol",
      "weight": 0.3,
      "notes": "Protocol fee for network services"
    }
  ],
  "context": {
    "derivedFrom": [
      {
        "type": "model",
        "id": "openai:gpt-4",
        "timestamp": "2026-03-01T00:00:00Z"
      }
    ]
  },
  "metadata": {
    "endpoint": "https://alice-inference.imajin.ai/v1",
    "sla": {
      "uptime": 0.99,
      "latencyP95": 500
    }
  }
}
```

### DID-Based Contributor Identity

Contributors in v0.2.0+ should be identified using Decentralized Identifiers (DIDs) for global uniqueness and verifiability.

**Supported DID methods:**
- `did:imajin:*` — Native Imajin ecosystem identities
- `did:key:*` — Cryptographic key-based identities
- `did:web:*` — Web-based identities
- Legacy string IDs are still supported but deprecated

**Example:**
```json
{
  "id": "did:imajin:alice:pub:abc123",
  "role": "operator",
  "weight": 0.5,
  "notes": "Primary node operator",
  "metadata": {
    "publicKey": "ed25519:...",
    "trustScore": 0.95
  }
}
```

### Settlement Interface (Abstract)

`.fair` v0.2.0 introduces an abstract settlement interface that supports multiple payment rails:

#### Phase 1: Fiat Settlement (Stripe)
- Batched payouts on fixed schedules (daily, weekly, monthly)
- Minimum payout thresholds to reduce transaction costs
- Traditional banking integration

#### Phase 2: On-Chain Settlement (Solana/MJN)
- Per-transaction settlement on Solana blockchain
- MJN token as native settlement currency
- Automated smart contract distribution

#### Phase 3: Local Node-to-Node Settlement
- Direct peer-to-peer settlement between trusted nodes
- Offline capability with eventual reconciliation
- Trust-graph-based credit lines

**Settlement Metadata Example:**
```json
{
  "metadata": {
    "settlement": {
      "method": "stripe",
      "batchingPeriod": "weekly",
      "minimumPayout": 10.00,
      "currency": "USD",
      "accounts": {
        "did:imajin:alice": "acct_stripe_abc123",
        "did:imajin:bob": "acct_stripe_xyz789"
      }
    }
  }
}
```

**Open Questions:**
- Dispute resolution mechanisms for contested splits
- Cross-border tax reporting and compliance
- Handling of failed/rejected payouts

### Trust Graph Integration

Attribution relationships in `.fair` manifests map to trust relationships in the Imajin trust graph, enabling:

1. **Reputation-Aware Routing**
   - Queries preferentially route to highly trusted contributors
   - Attribution weight influenced by trust score

2. **Quality Guarantees**
   - Contributors with proven track records get higher weight
   - Poor-performing contributors are downweighted or filtered

3. **Spam Prevention**
   - Unknown or low-trust identities have limited attribution share
   - Sybil resistance through web-of-trust

**Trust Metadata Example:**
```json
{
  "contributors": [
    {
      "id": "did:imajin:alice",
      "role": "operator",
      "weight": 0.6,
      "metadata": {
        "trustScore": 0.95,
        "attestations": [
          {
            "from": "did:imajin:bob",
            "weight": 0.8,
            "timestamp": "2026-01-15T00:00:00Z"
          }
        ]
      }
    }
  ]
}
```

### Query Attribution Chains

When a user query flows through multiple runtime modules (memory retrieval → context assembly → inference → response), each module contributes to the final result and should receive attribution.

**Multi-Module Attribution Example:**
```json
{
  "id": "query:user-session-123:query-456",
  "type": "runtime-module",
  "title": "Query Attribution Chain",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "memory:alice:db-1",
      "role": "operator",
      "weight": 0.2,
      "notes": "Memory retrieval service"
    },
    {
      "id": "inference:bob:gpt4",
      "role": "operator",
      "weight": 0.5,
      "notes": "Inference computation"
    },
    {
      "id": "mjn:protocol",
      "role": "protocol",
      "weight": 0.3,
      "notes": "Routing and orchestration"
    }
  ],
  "pricing": {
    "model": "metered",
    "unit": "query",
    "rate": 0.05,
    "currency": "USD"
  },
  "context": {
    "derivedFrom": [
      {
        "type": "memory-retrieval",
        "id": "memory:alice:db-1:retrieval-789",
        "timestamp": "2026-03-02T14:30:00Z"
      },
      {
        "type": "inference",
        "id": "inference:bob:gpt4:completion-012",
        "timestamp": "2026-03-02T14:30:01Z"
      }
    ]
  },
  "metadata": {
    "queryId": "query-456",
    "sessionId": "user-session-123",
    "tokensConsumed": 1500,
    "latencyMs": 420
  }
}
```

### Known Gaps and Open Questions

The following areas require further research and specification:

1. **Weight Algorithm (UNSOLVED)**
   - How to fairly compute attribution weights across diverse contribution types
   - Balancing objective metrics (tokens, latency) with subjective value (quality, creativity)
   - Handling contributions that span different time scales or have delayed impact

2. **Cross-Node Attribution**
   - Attribution when queries span multiple sovereign nodes
   - Handling trust boundaries between different operator networks
   - Reconciliation of competing attribution claims

3. **Privacy-Preserving Attribution**
   - How to prove contribution without revealing query content or user identity
   - Zero-knowledge proofs for metered billing
   - Differential privacy for aggregate statistics
   - See RFC-03 for HRPOS integration (patent pending)

4. **Dispute Resolution**
   - Mechanism for contesting attribution splits
   - Governance for protocol-level attribution rules
   - Handling of fraudulent or manipulated claims

5. **Offline/Local Settlement**
   - Credit lines based on trust graph
   - Reconciliation protocol for eventual consistency
   - Handling of network partitions or extended offline periods

These gaps are explicitly acknowledged. Contributions and research proposals welcome.

---

## v0.4.0: DFOS Integration

Imajin has integrated the DFOS protocol throughout its stack. The following sections describe how this changes core `.fair` semantics. All changes are additive — prior `.fair` manifests remain valid.

### Bilateral Attestations (Countersignatures)

Prior to v0.4.0, a `.fair` manifest was a single-signature document: the creator signed and the manifest was authoritative. Under DFOS integration, attribution uses **bilateral attestations** — both the issuer and the subject countersign.

This means: when a contributor is listed in a `.fair` manifest, their inclusion is not just declared by the manifest author — it is *attested* by both parties. Neither party can unilaterally assert the other's contribution or deny their own.

**Bilateral attestation structure:**

```json
{
  "attestation": {
    "issuer": "did:dfos:<creator-chain-id>",
    "subject": "did:dfos:<contributor-chain-id>",
    "role": "artist",
    "share": 0.4,
    "issuerSignature": "<ed25519-sig-by-creator>",
    "subjectSignature": "<ed25519-sig-by-contributor>",
    "timestamp": "2026-03-23T00:00:00Z"
  }
}
```

**Settlement layer behavior:** The settlement layer treats countersigned attestations as the authoritative record. An uncountersigned attribution share is pending — it does not route payments until the subject countersigns. This prevents unilateral attribution claims from triggering payouts.

---

### CID-Backed Asset Identity and Content Chains

Assets in v0.4.0+ are identified by **Content Identifiers (CIDs)** — cryptographic hashes of the asset content — backed by DFOS content chains.

**A `.fair` manifest creation is a content chain genesis event.** When a creator publishes a `.fair` manifest, they are initiating a DFOS content chain: an append-only chain of signed operations anchored to the asset's CID. The genesis block contains the initial attribution manifest. Subsequent operations (amendments, licensing events, sampling declarations) append to the chain.

```json
{
  "id": "cid:bafybeig...",
  "type": "track",
  "contentChain": {
    "genesisBlock": "bafybeig...",
    "chainId": "dfos:chain:abc123",
    "operator": "did:dfos:relay-imajin"
  },
  "contributors": [...]
}
```

**Properties:**
- The CID is stable: it is derived from content, not from a platform-issued ID
- The content chain records the full history of attribution amendments
- Any node holding the content can verify the manifest against the CID
- Transferring content between nodes transfers the chain, not a database record

---

### Cross-Graph Deduplication

Because asset identity is content-addressed by CID, the same asset appearing on multiple DFOS chains is detectable without coordination.

**Cross-graph dedup rule:** If two DFOS chains contain the same content hash, they reference the same asset. Attribution from both chains is merged and deduplicated at query time. This enables:

- **Discovery:** A creator publishes on one node; a downstream node using the same content discovers the original attribution chain automatically
- **Conflict detection:** If two chains carry different attribution for the same CID, this is a detectable conflict, surfaced to the involved parties for resolution
- **Attribution inheritance:** When content is remixed, the derived work's `.fair` manifest references the source CID, and the original attribution chain is transitively resolved

---

### Transaction Attestations

Every transactional event in v0.4.0+ produces a **bilateral attestation** as a cryptographic proof that both parties agreed:

| Transaction Type | Bilateral Attestation Produced |
|-----------------|-------------------------------|
| Marketplace purchase | Buyer + seller countersignature on price and content CID |
| Tip / gratuity | Sender + recipient countersignature on amount and context |
| Course enrollment | Student + instructor countersignature on terms and access |
| License grant | Licensor + licensee countersignature on scope and duration |
| Sampling clearance | Source artist + sampling artist countersignature on terms |

These attestations are stored on the relevant DFOS content chains. They are:
- Immutable: once both parties have signed, the record cannot be altered
- Portable: any node can verify the attestation against the public keys
- Auditable: the full history of a content chain shows every transaction involving the asset

**Settlement integration:** Settlement instructions in `.fair` manifests now reference transaction attestation IDs rather than raw payment metadata. This binds the settlement record to the proof of mutual agreement.

---

### Revocation Tiers

v0.4.0 introduces a three-tier revocation model for attribution and licensing claims, implemented as chain operations on the DFOS content chain:

| Tier | Operation | Effect | Reversible? |
|------|-----------|--------|-------------|
| **Withdraw** | `chain.withdraw` | Removes the claim from active routing. Settlement pauses. Historical record preserved. | Yes — re-publication restores |
| **Soft Revoke** | `chain.revoke.soft` | Marks the claim as revoked. Downstream nodes receive revocation signal. Settlement stops. | Yes — requires counterparty consent |
| **Hard Revoke** | `chain.revoke.hard` | Permanently invalidates the claim. Burned into the chain as an immutable termination event. | No |

**Revocation propagation:** Revocation signals propagate through DFOS relay nodes. Nodes caching attribution data MUST honor revocation signals within their stated freshness window. Hard revocations MUST be honored immediately upon receipt.

**Partial revocation:** A creator may revoke a specific licensing term (e.g., revoke training rights) without revoking the full manifest. The content chain records which terms are active and which have been revoked.

```json
{
  "revocation": {
    "manifestCID": "bafybeig...",
    "tier": "soft",
    "revokedTerms": ["train"],
    "reason": "Training consent withdrawn pending updated terms",
    "signature": "<ed25519-sig>",
    "timestamp": "2026-03-23T00:00:00Z"
  }
}
```

---

## References

- [RFC-01: Commit Attribution](../rfcs/RFC-01-commit-attribution.md)
- [RFC-02: Runtime Modules](../rfcs/RFC-02-runtime-modules.md)
- [RFC-03: Memory Attribution](../rfcs/RFC-03-memory-attribution.md)
- [RFC-04: Settlement](../rfcs/RFC-04-settlement.md)
- [MJN Protocol Documentation](https://imajin.ai/docs/mjn)
- [Imajin Trust Graph](https://imajin.ai/docs/trust-graph)
