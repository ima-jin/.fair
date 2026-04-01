# .fair in 5 Minutes

## What is it?

`.fair` is a signed JSON manifest that travels with your content and says who made it, who can access it, and who gets paid.

It's not a blockchain. It's not an app. It's a JSON structure — like `package.json` for attribution — that can be stored as a file, embedded in a database, or anchored to a DFOS content chain.

## The simplest manifest

```json
{
  "fair": "1.0",
  "id": "my-song-123",
  "type": "audio/mpeg",
  "owner": "did:imajin:alice",
  "created": "2026-04-01T12:00:00Z",
  "access": "public",
  "attribution": [
    { "did": "did:imajin:alice", "role": "artist", "share": 0.6 },
    { "did": "did:imajin:bob", "role": "producer", "share": 0.4 }
  ]
}
```

That's a complete manifest. When someone buys or tips this work, 60% goes to Alice, 40% to Bob. The `access` field says anyone can see it.

## Do I need a DID?

No. You can start with plain string IDs:

```json
{ "did": "alice@example.com", "role": "artist", "share": 1.0 }
```

But with a DID, you get:
- **Signing** — the manifest is cryptographically signed by the creator's Ed25519 key
- **Federation** — the manifest becomes a DFOS content chain entry, replicated across relay nodes
- **Verification** — anyone can verify the attribution against the creator's identity chain
- **Scope tracking** — access changes are recorded as chain operations

Plain strings work for prototyping. DIDs make it real.

## Access scope

Every manifest has an `access` field that controls who can see the asset:

```json
"access": "public"
"access": "private"
"access": { "type": "conversation", "conversationDid": "did:imajin:conv:abc" }
"access": { "type": "trust-graph", "allowedDids": ["did:imajin:bob"] }
```

**The same asset can change scope.** Upload a photo to a chat — it's scoped to that conversation. Later list it on a marketplace — scope changes to public. Each change is an operation on the content chain, so the full access history is preserved.

## Revenue splits

The `attribution` array defines who gets credit. The `distributions` array (optional) defines who gets paid — useful when the payer differs from the creator:

```json
{
  "attribution": [
    { "did": "did:imajin:alice", "role": "artist", "share": 0.6 },
    { "did": "did:imajin:bob", "role": "producer", "share": 0.4 }
  ],
  "distributions": [
    { "did": "did:imajin:alice", "role": "artist", "share": 0.55 },
    { "did": "did:imajin:bob", "role": "producer", "share": 0.35 },
    { "did": "did:imajin:venue", "role": "venue", "share": 0.10 }
  ]
}
```

Attribution = who made it. Distribution = who gets paid. They're often the same, but not always.

## Signing

Manifests are signed with the creator's Ed25519 key (the same key backing their DID):

```json
{
  "signature": {
    "algorithm": "ed25519",
    "value": "a1b2c3...",
    "publicKeyRef": "did:imajin:alice"
  }
}
```

A signed manifest is a tamper-evident record. Change the attribution, the signature breaks. The platform can add a countersignature (`platformSignature`) to endorse the manifest.

## How it works in practice

### Upload to chat
1. You send an image in a conversation
2. The media service generates a `.fair` manifest: `access: { type: "conversation", conversationDid: "..." }`
3. Manifest is stored alongside the asset in the database
4. Only conversation members can access the asset

### List on marketplace
1. You create a market listing with the same image
2. The manifest is updated: `access: "public"`, `distributions` include platform fee
3. Someone buys it → settlement reads the manifest → splits payment per the shares

### Track a performance
```json
{
  "fair": "1.0",
  "id": "set-summer-camp-2026",
  "type": "performance",
  "owner": "did:imajin:dj-alice",
  "created": "2026-07-15T22:00:00Z",
  "access": "public",
  "attribution": [
    { "did": "did:imajin:dj-alice", "role": "performer", "share": 0.7 },
    { "did": "did:imajin:summer-camp", "role": "venue", "share": 0.2 },
    { "did": "did:imajin:sound-tech", "role": "engineer", "share": 0.1 }
  ]
}
```

## What .fair is NOT

- **Not a blockchain.** It's a data format. No tokens required.
- **Not DRM.** It doesn't restrict access. It documents contribution and intent.
- **Not a platform.** Any system can read and write `.fair` manifests.
- **Not mandatory.** Use as much or as little of the schema as you need.

## With DFOS

When backed by a DID, a `.fair` manifest becomes a content chain entry on the [DFOS](https://github.com/metalabel/dfos) network:

- **Genesis** — creating a manifest starts a content chain for that asset
- **Amendments** — scope changes, new contributors, licensing updates append to the chain
- **Federation** — the chain replicates across relay nodes automatically
- **Verification** — any node can replay the chain and verify the full history

The manifest is the human-readable format. The chain is the cryptographic proof.

## Go deeper

- [Full Specification](../spec/SPEC.md) — Complete schema reference
- [Examples](../examples/) — Sample manifests for music, events, code
- [RFC-01: Commit Attribution](../rfcs/RFC-01-commit-attribution.md) — Auto-generate from git
- [RFC-02: Runtime Modules](../rfcs/RFC-02-runtime-modules.md) — Attribution for AI/compute services

## The bigger picture

`.fair` is the attribution layer in [Imajin](https://imajin.ai)'s sovereign infrastructure stack. The ecosystem adds identity ([DFOS](https://github.com/metalabel/dfos) chains), payments (Stripe today, MJN token later), and trust graphs on top.

You don't need Imajin to use `.fair`. You don't need a token. You don't need a DID. Start with a JSON object. Adopt more when it's useful.
