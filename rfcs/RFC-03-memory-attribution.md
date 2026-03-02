# RFC-03: Memory and Context Attribution

**Status**: Draft
**Author**: Imajin Team
**Created**: 2026-03-02
**Updated**: 2026-03-02

## Abstract

This RFC addresses attribution for memory and context modules in distributed AI systems. It covers retrieval attribution, quality benchmarking, privacy-preserving contribution proofs, and integration with the Human Router Protocol (HRPOS).

## Motivation

Memory and context are **critical infrastructure** for modern AI:

- RAG (Retrieval-Augmented Generation) systems depend on high-quality context
- Long-term memory enables personalized, stateful interactions
- Context assembly is non-trivial: retrieval, reranking, filtering, summarization

Yet memory providers are often **invisible** in attribution chains. This RFC ensures:

1. **Fair compensation** — Memory operators rewarded for quality data
2. **Privacy preservation** — Prove contribution without revealing content
3. **Quality incentives** — Better memory = higher attribution weight
4. **Transparent provenance** — Users know where context came from

## Proposal

### Memory Module Manifest

Memory modules declare `.fair` manifests similar to inference modules:

```json
{
  "id": "memory:bob:postgres-knowledge-base",
  "type": "runtime-module",
  "title": "Bob's Knowledge Base (PostgreSQL + pgvector)",
  "version": "0.2.0",
  "capabilities": [
    "vector-search",
    "semantic-retrieval",
    "full-text-search"
  ],
  "pricing": {
    "model": "metered",
    "unit": "query",
    "rate": 0.01,
    "currency": "USD"
  },
  "contributors": [
    {
      "id": "did:imajin:bob",
      "role": "operator",
      "weight": 0.8,
      "notes": "Memory infrastructure and curation"
    },
    {
      "id": "mjn:protocol",
      "role": "protocol",
      "weight": 0.2,
      "notes": "Protocol fee"
    }
  ],
  "metadata": {
    "endpoint": "https://bob-memory.imajin.ai/v1",
    "storage": {
      "type": "postgres",
      "size": "500GB",
      "documents": 1200000,
      "dimensions": 1536
    },
    "sla": {
      "latencyP95Ms": 50,
      "uptime": 0.995
    },
    "qualityMetrics": {
      "recallAt10": 0.87,
      "ndcgAt10": 0.82,
      "userSatisfaction": 4.6
    }
  }
}
```

### Retrieval Attribution

When memory is retrieved for a query:

```json
{
  "id": "retrieval:bob:query-789",
  "type": "runtime-module",
  "title": "Memory Retrieval Event",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "memory:bob:postgres-knowledge-base",
      "role": "operator",
      "weight": 1.0,
      "notes": "Retrieved 5 documents, 2000 tokens"
    }
  ],
  "context": {
    "derivedFrom": [
      {
        "type": "document",
        "id": "doc:abc123",
        "timestamp": "2025-06-15T00:00:00Z",
        "retrievalScore": 0.92
      },
      {
        "type": "document",
        "id": "doc:def456",
        "timestamp": "2025-08-20T00:00:00Z",
        "retrievalScore": 0.89
      }
    ]
  },
  "metadata": {
    "queryEmbedding": "[0.123, -0.456, ...]",
    "topK": 5,
    "documentsReturned": 5,
    "tokensReturned": 2000,
    "latencyMs": 35,
    "method": "cosine-similarity"
  }
}
```

**Key fields:**
- `derivedFrom`: List of retrieved documents with scores
- `tokensReturned`: Amount of context contributed
- `retrievalScore`: Relevance scores (for quality weighting)

### Multi-Source Context Assembly

If context comes from multiple memory sources:

```json
{
  "id": "context:query-789",
  "type": "runtime-module",
  "title": "Assembled Context",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "memory:bob:postgres-kb",
      "role": "operator",
      "weight": 0.6,
      "notes": "3 documents, 1500 tokens"
    },
    {
      "id": "memory:carol:pinecone-arxiv",
      "role": "operator",
      "weight": 0.4,
      "notes": "2 documents, 500 tokens"
    }
  ],
  "context": {
    "derivedFrom": [
      {
        "type": "memory-retrieval",
        "id": "retrieval:bob:query-789-1",
        "timestamp": "2026-03-02T14:30:00.123Z"
      },
      {
        "type": "memory-retrieval",
        "id": "retrieval:carol:query-789-2",
        "timestamp": "2026-03-02T14:30:00.156Z"
      }
    ]
  },
  "metadata": {
    "totalDocuments": 5,
    "totalTokens": 2000,
    "sources": ["postgres-kb", "pinecone-arxiv"]
  }
}
```

**Weight calculation**: Proportional to token count (60% vs. 40%).

### Quality Benchmarking

Memory quality is hard to measure objectively. Proposed metrics:

#### 1. Retrieval Quality (Objective)

Benchmark against standard datasets:

- **Recall@K**: Fraction of relevant docs in top K results
- **NDCG@K**: Normalized Discounted Cumulative Gain
- **MRR**: Mean Reciprocal Rank

Example:

```json
{
  "qualityMetrics": {
    "benchmark": "beir-msmarco",
    "recallAt10": 0.87,
    "ndcgAt10": 0.82,
    "mrr": 0.79,
    "lastEvaluated": "2026-02-15T00:00:00Z"
  }
}
```

#### 2. User Feedback (Subjective)

Track user satisfaction with retrieved context:

- Thumbs up/down on responses
- Explicit feedback on context relevance
- A/B testing across memory providers

Example:

```json
{
  "qualityMetrics": {
    "userSatisfaction": 4.6,
    "totalQueries": 120000,
    "positiveFeedback": 0.82,
    "negativeFeedback": 0.05
  }
}
```

#### 3. Downstream Impact

Measure how retrieved context affects final inference quality:

- Does higher retrieval score → better model output?
- Does user accept/reject responses based on context source?

**Open question**: How to isolate memory quality from inference quality?

### Privacy-Preserving Attribution

**Problem**: Proving that memory was used without revealing query content or retrieved documents.

#### Use Case: Private Queries

User wants to:
- Query memory without memory operator seeing the query
- Compensate memory operator fairly
- Prove attribution to auditors/protocol

#### Approach 1: Zero-Knowledge Proofs (ZKP)

Memory operator generates proof:

```
PROOF = ZKP(
  statement: "I retrieved K documents for query Q",
  witness: {query: Q, documents: [D1, D2, ...], scores: [S1, S2, ...]}
)
```

Client verifies proof without learning Q or D_i.

**Status**: Research prototype. High overhead for production.

#### Approach 2: Homomorphic Encryption

Encrypt query before sending to memory:

```
encrypted_query = Enc(query, public_key)
memory.search(encrypted_query) → encrypted_results
```

Decrypt results locally.

**Status**: Too slow for real-time retrieval.

#### Approach 3: Trusted Execution Environment (TEE)

Run memory retrieval in secure enclave (Intel SGX, AWS Nitro):

- Query encrypted in transit
- Decrypted inside TEE
- Results returned encrypted
- Attestation proves correct execution

**Status**: Practical but requires specialized hardware.

#### Approach 4: HRPOS (Human Router Protocol - Patent Pending)

**Patent #63900179**: Human Router Protocol for privacy-preserving attribution.

**Key idea**: Aggregate attribution across multiple queries without linking individual queries to users.

**Mechanism**:
1. Memory operator tracks query hashes (not content)
2. Protocol aggregates attribution per time window (e.g., hourly)
3. Settlement based on aggregate usage, not per-query tracking
4. Differential privacy to prevent user fingerprinting

**Benefits**:
- No query content exposure
- Scalable (batch processing)
- Regulatory compliant (GDPR, CCPA)

**Limitations**:
- Coarser granularity (can't attribute individual queries)
- Requires trusted protocol layer

**Implementation status**: Prototype in Imajin ecosystem.

### Document-Level Attribution

If a memory module retrieves a document created by a third party, attribution should flow upstream:

```json
{
  "id": "doc:abc123",
  "type": "project",
  "title": "How to Train Large Language Models",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "did:imajin:author-alice",
      "role": "writer",
      "weight": 1.0,
      "notes": "Original author"
    }
  ],
  "context": {
    "source": "manual",
    "sourceId": "doc:abc123"
  },
  "metadata": {
    "license": "CC-BY-4.0",
    "publishedAt": "2025-06-15T00:00:00Z"
  }
}
```

When this document is retrieved:

```json
{
  "contributors": [
    {
      "id": "memory:bob:postgres-kb",
      "role": "operator",
      "weight": 0.3,
      "notes": "Storage and retrieval infrastructure"
    },
    {
      "id": "did:imajin:author-alice",
      "role": "writer",
      "weight": 0.7,
      "notes": "Original document creator"
    }
  ]
}
```

**Weight split**: Infrastructure vs. content creation.

**Open question**: How to verify document provenance? Cryptographic signatures? Content hashing?

### Temporal Attribution Decay

Should old documents receive less attribution than recent ones?

**Argument for decay**:
- Old information may be stale or outdated
- Recent contributors should be rewarded for currency

**Argument against decay**:
- Foundational knowledge has lasting value
- Penalizes archival/historical content

**Proposed approach**: Make decay **optional** via metadata:

```json
{
  "metadata": {
    "attributionDecay": {
      "enabled": true,
      "halfLifeDays": 365,
      "minWeight": 0.1
    }
  }
}
```

Weight decays exponentially with time since publication.

## Open Questions

1. **Multi-Hop Retrieval**
   - If memory A references memory B (graph traversal), how to split attribution?
   - Should intermediate hops receive credit?

2. **Negative Attribution**
   - If retrieved context leads to a bad response, should memory operator be penalized?
   - How to distinguish memory quality from inference quality?

3. **Synthetic Data**
   - If memory contains AI-generated documents, who owns attribution?
   - Should synthetic data be disclosed?

4. **Right to Be Forgotten**
   - If a document is deleted (GDPR), how to retroactively adjust attribution?
   - Does past compensation need to be clawed back?

5. **Cross-Language Retrieval**
   - If query is in English but retrieved docs are in Spanish, who handles translation attribution?

## Implementation Checklist

- [ ] Memory module manifest schema
- [ ] Retrieval attribution tracking
- [ ] Quality benchmarking framework
- [ ] Privacy-preserving proof-of-retrieval (HRPOS integration)
- [ ] Document-level attribution chaining
- [ ] Temporal decay configuration

## Prior Art

- **BEIR Benchmark** — Retrieval quality evaluation
- **Information Retrieval Metrics** — NDCG, MRR, Recall@K
- **Differential Privacy** — Aggregate statistics without individual exposure
- **Zero-Knowledge Proofs** — Private computation verification

## References

- [.fair Specification v0.3](../spec/SPEC.md)
- [RFC-02: Runtime Modules](./RFC-02-runtime-modules.md)
- [RFC-04: Settlement](./RFC-04-settlement.md)
- [HRPOS Patent Filing #63900179](https://patents.google.com/) (pending publication)
- [BEIR: A Heterogeneous Benchmark for Information Retrieval](https://arxiv.org/abs/2104.08663)

## Changelog

- **2026-03-02**: Initial draft
