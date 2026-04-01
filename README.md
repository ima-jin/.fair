# .fair

**Attribution and compensation manifests for creative work, code, and runtime services.**

`.fair` is an open attribution standard that defines who contributed to a piece of work, how it should be credited, and how value should be distributed. It's part of the [Imajin](https://imajin.ai) sovereign infrastructure ecosystem.

---

## What is .fair?

`.fair.json` manifests are plain-text metadata files that provide:

- **Attribution** — Who created this work and what roles did they play?
- **Compensation** — How should revenue or value be split among contributors?
- **Provenance** — Where did this work come from? What is it derived from?
- **License** — What are the terms of use?

The format is designed to be:
- **Portable** — Works across platforms, protocols, and ecosystems
- **Composable** — Manifests can reference and build on other manifests
- **Machine-readable** — Structured for automated processing and settlement
- **Human-friendly** — Plain JSON that anyone can read and write

---

## Use Cases

### Creative Content (v0.1.0, April 2025)
- Music tracks and albums
- Collaborative creative projects
- Open-source software
- Datasets and research artifacts

### Runtime Services (v0.2.0, March 2026)
- AI inference endpoints
- Memory and context modules
- Embedding services
- Search and retrieval systems

`.fair` enables transparent attribution chains that follow value through entire computational graphs — from the original dataset creators, through model trainers, to runtime service operators.

---

## Quick Start

### Basic Example

```json
{
  "id": "project-abc123",
  "type": "project",
  "title": "Open Source ML Library",
  "version": "0.2.0",
  "contributors": [
    {
      "id": "did:imajin:alice",
      "role": "engineer",
      "weight": 0.6,
      "notes": "Core architecture and implementation"
    },
    {
      "id": "did:imajin:bob",
      "role": "engineer",
      "weight": 0.4,
      "notes": "Documentation and testing"
    }
  ],
  "metadata": {
    "license": "MIT",
    "tags": ["machine-learning", "open-source"]
  }
}
```

### Runtime Module Example

```json
{
  "id": "inference-xyz789",
  "type": "runtime-module",
  "title": "GPT-4 Inference Service",
  "version": "0.2.0",
  "capabilities": ["text-generation", "chat"],
  "pricing": {
    "model": "metered",
    "unit": "token",
    "rate": 0.00003
  },
  "contributors": [
    {
      "id": "did:imajin:operator",
      "role": "operator",
      "weight": 0.7
    },
    {
      "id": "mjn:protocol",
      "role": "protocol",
      "weight": 0.3
    }
  ]
}
```

See [examples/](./examples/) for more examples.

---

## Documentation

- **[Specification](./spec/SPEC.md)** — Complete schema definition and implementation guide
- **[RFCs](./rfcs/)** — Design proposals and implementation details
  - [RFC-01: Commit Attribution](./rfcs/RFC-01-commit-attribution.md)
  - [RFC-02: Runtime Modules](./rfcs/RFC-02-runtime-modules.md)
  - [RFC-03: Memory Attribution](./rfcs/RFC-03-memory-attribution.md)
  - [RFC-04: Settlement](./rfcs/RFC-04-settlement.md)
- **[Examples](./examples/)** — Sample manifests for different use cases
- **[Guides](./docs/)** — Implementation guides and architecture docs

---

## Validation

Validate your `.fair.json` files against the schema:

```bash
npx ajv-cli validate -s schema/fair.schema.json -d yourfile.fair.json
```

Or use the setup script:

```bash
node setup.js
```

---

## Key Concepts

### Attribution Chains
Every `.fair` manifest can reference upstream dependencies through the `context.derivedFrom` field, creating transparent attribution chains that trace value back to original creators.

### DID-Based Identity
Contributors are identified using Decentralized Identifiers (DIDs), with native support for `did:imajin:*` identities in the Imajin ecosystem.

### Flexible Settlement
The standard supports multiple settlement mechanisms:
- **Phase 1**: Traditional fiat payments (Stripe)
- **Phase 2**: On-chain settlement (Solana/MJN)
- **Phase 3**: Peer-to-peer local settlement

### Trust Graph Integration
Attribution relationships map to trust relationships in the Imajin trust graph, enabling reputation-aware routing and quality guarantees.

---

## Version History

- **v0.4.0** (Mar 2026) — DFOS integration: bilateral attestations, CID-backed content chains, revocation tiers
- **v0.2.0** (Mar 2026) — Runtime modules, RFCs, DID support, settlement abstraction
- **v0.1.0** (Apr 2025) — Initial release for creative content attribution

---

## Ecosystem

`.fair` is part of the [Imajin](https://imajin.ai) sovereign infrastructure project:

- **[DFOS](https://github.com/metalabel/dfos)** — Federated identity and content chain protocol
- **MJN** — Settlement token and trust graph

---

## Contributing

This is an open standard. Contributions, feedback, and implementations are welcome.

- **Issues**: [github.com/ima-jin/.fair/issues](https://github.com/ima-jin/.fair/issues)
- **Discussions**: [github.com/ima-jin/.fair/discussions](https://github.com/ima-jin/.fair/discussions)
- **RFCs**: Submit proposals as pull requests to `rfcs/`

---

## License

CC0 1.0 Universal — public domain dedication.

The `.fair` format is freely usable by anyone for any purpose. Works described by `.fair.json` manifests may have their own licenses.

---

**[ima-jin](https://github.com/ima-jin)** • **[imajin.ai](https://imajin.ai)**
