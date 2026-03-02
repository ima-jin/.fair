# RFC-02: Runtime Module Attribution

**Status**: Draft
**Author**: Imajin Team
**Created**: 2026-03-02
**Updated**: 2026-03-02

## Abstract

This RFC defines how runtime computational modules (inference, memory, embedding, search) declare `.fair` manifests to enable transparent attribution and compensation across distributed service graphs.

## Motivation

Traditional software attribution focuses on static artifacts (code, datasets, documents). But modern AI systems are **runtime compositions** of multiple services:

- User query → Memory retrieval → Context assembly → Inference → Response

Each service contributes value and incurs cost. `.fair` should support:

1. **Per-query attribution** — Track value flow for each request
2. **Module discovery** — Advertise capabilities and pricing
3. **Revenue splitting** — Distribute payment across the service graph
4. **Quality signals** — Reputation-based routing and filtering

## Proposal

### Module Manifest Schema

Runtime modules publish `.fair` manifests at a well-known endpoint or in a registry:

**Core fields:**
- `type`: `"runtime-module"`
- `capabilities`: Array of service types
- `pricing`: Pricing model (metered, fixed, hybrid)
- `endpoint`: Service URL (optional)
- `contributors`: Operators and protocol fees

**Example: Inference Module**

```json
{
  "id": "inference:gpt4:alice-node-7",
  "type": "runtime-module",
  "title": "GPT-4 Inference Node (Alice)",
  "version": "0.2.0",
  "capabilities": [
    "text-generation",
    "chat",
    "code-completion",
    "function-calling"
  ],
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
      "notes": "Node operator, infrastructure costs"
    },
    {
      "id": "mjn:protocol",
      "role": "protocol",
      "weight": 0.3,
      "notes": "MJN protocol fee for routing and trust graph"
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
    "modelVersion": "gpt-4-0125-preview",
    "sla": {
      "uptime": 0.99,
      "latencyP95Ms": 500,
      "rateLimitRPM": 10000
    },
    "regions": ["us-west-2", "eu-central-1"]
  }
}
```

### Pricing Models

#### Metered

Pay-per-use based on consumption:

```json
{
  "pricing": {
    "model": "metered",
    "unit": "token",
    "rate": 0.00003,
    "currency": "USD"
  }
}
```

**Units**: `token`, `query`, `second`, `byte`, `call`

#### Fixed

Flat rate per time period or session:

```json
{
  "pricing": {
    "model": "fixed",
    "unit": "hour",
    "rate": 5.00,
    "currency": "USD"
  }
}
```

#### Hybrid

Base fee + metered overage:

```json
{
  "pricing": {
    "model": "hybrid",
    "baseFee": 1.00,
    "baseUnits": 10000,
    "unit": "token",
    "overageRate": 0.00004,
    "currency": "USD"
  }
}
```

### Multi-Module Query Attribution

When a query flows through multiple modules, generate a **query-level manifest**:

```json
{
  "id": "query:session-abc:query-123",
  "type": "runtime-module",
  "title": "User Query Attribution Chain",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "memory:bob:postgres-1",
      "role": "operator",
      "weight": 0.15,
      "notes": "Memory retrieval: 5 documents, 2000 tokens"
    },
    {
      "id": "embedding:carol:cohere-1",
      "role": "operator",
      "weight": 0.05,
      "notes": "Embedding generation for retrieval"
    },
    {
      "id": "inference:alice:gpt4",
      "role": "operator",
      "weight": 0.50,
      "notes": "Inference: 1500 tokens generated"
    },
    {
      "id": "mjn:protocol",
      "role": "protocol",
      "weight": 0.30,
      "notes": "Protocol fee: routing, orchestration, trust"
    }
  ],
  "pricing": {
    "model": "metered",
    "unit": "query",
    "rate": 0.08,
    "currency": "USD"
  },
  "context": {
    "derivedFrom": [
      {
        "type": "memory-retrieval",
        "id": "memory:bob:postgres-1:retrieval-xyz",
        "timestamp": "2026-03-02T14:30:00.123Z"
      },
      {
        "type": "embedding",
        "id": "embedding:carol:cohere-1:embed-456",
        "timestamp": "2026-03-02T14:30:00.089Z"
      },
      {
        "type": "inference",
        "id": "inference:alice:gpt4:completion-789",
        "timestamp": "2026-03-02T14:30:01.456Z"
      }
    ]
  },
  "metadata": {
    "queryId": "query-123",
    "sessionId": "session-abc",
    "userId": "did:imajin:user-dave",
    "totalLatencyMs": 1420,
    "tokensConsumed": 1500,
    "tokensRetrieved": 2000,
    "documentsRetrieved": 5
  }
}
```

### Revenue Split Calculation

For a $0.08 query:

- Memory (15%): $0.012
- Embedding (5%): $0.004
- Inference (50%): $0.040
- Protocol (30%): $0.024

Each module operator receives their share according to settlement schedule (see RFC-04).

## Module Discovery and Routing

### Registry Model

Modules register manifests in a distributed registry (DHT, blockchain, or federated):

```
POST /v1/registry/modules
{
  "manifest": { ... },
  "signature": "..."
}
```

Clients query by capability:

```
GET /v1/registry/modules?capability=text-generation&region=us-west
```

### Trust-Based Routing

Queries route to modules based on:

1. **Capability match** — Does module support required features?
2. **Pricing** — Lowest cost within quality threshold?
3. **Trust score** — Operator reputation in trust graph
4. **SLA guarantees** — Uptime, latency, rate limits
5. **User preferences** — Explicit operator whitelist/blacklist

**Routing weight formula (simplified)**:

```
score = (trustScore * 0.5) + (1 / price * 0.3) + (slaUptime * 0.2)
```

Route to highest-scoring module.

## Capability Taxonomy

**Inference:**
- `text-generation`
- `chat`
- `code-completion`
- `function-calling`
- `embeddings` (output)
- `image-generation`
- `speech-to-text`

**Memory:**
- `vector-search`
- `semantic-retrieval`
- `graph-traversal`
- `full-text-search`

**Embedding:**
- `text-embedding`
- `image-embedding`
- `multimodal-embedding`

**Other:**
- `reranking`
- `summarization`
- `translation`
- `moderation`

## Attribution Weight Algorithm (UNSOLVED)

How to fairly split revenue across modules? Approaches:

### 1. Cost-Based

Weight proportional to compute cost:

```
weight_module = cost_module / total_cost
```

**Pros**: Objective, aligns with expenses
**Cons**: Ignores value, quality, or scarcity

### 2. Time-Based

Weight by latency contribution:

```
weight_module = latency_module / total_latency
```

**Pros**: Penalizes slow modules
**Cons**: Doesn't reflect value (fast ≠ valuable)

### 3. Token-Based (for LLM queries)

Weight by token consumption:

```
weight_inference = tokens_generated / (tokens_generated + tokens_retrieved)
weight_memory = tokens_retrieved / (tokens_generated + tokens_retrieved)
```

**Pros**: Natural unit for LLM workloads
**Cons**: Ignores embedding, reranking, orchestration costs

### 4. Negotiated/Manual

Module operators specify minimum share in manifest:

```json
{
  "pricing": {
    "model": "metered",
    "unit": "query",
    "minShare": 0.4
  }
}
```

Router rejects requests if shares don't sum to ≤ 1.0.

**Pros**: Market-driven
**Cons**: Complex negotiation, no standard

### 5. Hybrid

Combine multiple signals with configurable weights.

**Current status**: UNSOLVED. Implementations should experiment and report findings.

## Metadata and Quality Signals

Modules should expose quality metrics:

```json
{
  "metadata": {
    "sla": {
      "uptime": 0.995,
      "latencyP50Ms": 120,
      "latencyP95Ms": 450,
      "latencyP99Ms": 800,
      "rateLimitRPM": 10000
    },
    "quality": {
      "errorRate": 0.001,
      "userSatisfactionScore": 4.7,
      "benchmarkScore": {
        "mmlu": 0.89,
        "humaneval": 0.82
      }
    },
    "capacity": {
      "maxConcurrentRequests": 100,
      "currentLoad": 0.34
    }
  }
}
```

Clients can filter or weight routing based on these metrics.

## Security and Trust

### Identity Verification

- Modules MUST sign manifests with DID private key
- Clients verify signatures before routing queries
- Fraudulent manifests reported to trust graph

### Rate Limiting and Abuse

- Modules enforce rate limits per client DID
- Protocol tracks abusive clients (spam, non-payment)
- Trust graph penalizes bad actors

### Data Privacy

- Modules MUST NOT log query content without user consent
- Privacy-preserving attribution via HRPOS (see RFC-03)
- Audit logs for compliance (GDPR, CCPA)

## Open Questions

1. **Dynamic Pricing**
   - Should modules adjust pricing based on demand/supply?
   - How to prevent price manipulation?

2. **Multi-Tenant Attribution**
   - If one module serves multiple clients simultaneously, how to attribute infrastructure costs?

3. **Latency Penalties**
   - Should slow modules receive reduced attribution?
   - Who defines acceptable latency thresholds?

4. **Cascading Failures**
   - If a memory module fails mid-query, who pays for wasted compute?

5. **Cross-Chain Settlement**
   - How to handle modules operating on different blockchains (Solana, Ethereum, etc.)?

## Implementation Checklist

- [ ] Module manifest schema in JSON Schema
- [ ] Registry API specification (REST or GraphQL)
- [ ] Trust-based routing algorithm
- [ ] Pricing model validation
- [ ] Query attribution aggregation logic
- [ ] Settlement integration (see RFC-04)

## Prior Art

- **OpenAPI/Swagger** — Service capability declaration
- **Kubernetes Service Mesh** — Traffic routing and observability
- **Stripe Connect** — Multi-party payment splitting
- **GraphQL Federation** — Distributed schema composition

## References

- [.fair Specification v0.3](../spec/SPEC.md)
- [RFC-03: Memory Attribution](./RFC-03-memory-attribution.md)
- [RFC-04: Settlement](./RFC-04-settlement.md)
- [MJN Protocol Trust Graph](https://imajin.ai/docs/trust-graph)

## Changelog

- **2026-03-02**: Initial draft
