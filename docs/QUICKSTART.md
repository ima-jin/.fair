# .fair in 5 Minutes

## What is it?

`.fair` is a JSON file that sits next to your content and says who made it and who gets paid.

That's it. It's not a protocol. It's not a blockchain. It's not an app you install. It's a `.fair.json` file — like `package.json` for attribution.

## Do I need an identity?

No. You can write a `.fair.json` file right now with whatever IDs you want:

```json
{
  "id": "my-song-123",
  "type": "track",
  "title": "My Song",
  "version": "0.3.0",
  "contributors": [
    { "id": "alice@example.com", "role": "artist", "weight": 0.6 },
    { "id": "bob@example.com", "role": "producer", "weight": 0.4 }
  ]
}
```

If you want verifiable, portable identity that works across platforms, you can use a DID (`did:imajin:alice`). But plain strings work fine. Start simple.

## Do I need a special app or browser?

No. `.fair` files are plain JSON. You can:

- Create them by hand in any text editor
- Generate them with any programming language
- Validate them with the JSON schema (`schema/fair.schema.json`)
- Read them with `cat`, `jq`, or any JSON parser

There's no special runtime, no browser extension, no SDK required.

## How does it actually work?

### Step 1: Create a .fair.json file

Put it next to whatever you're attributing:

```
my-album/
├── track-01.mp3
├── track-01.fair.json
├── track-02.mp3
└── track-02.fair.json
```

### Step 2: Define who made it

Each contributor gets an `id`, a `role`, and a `weight` (their share, 0 to 1):

```json
{
  "id": "collab-track-01",
  "type": "track",
  "title": "Opening Track",
  "version": "0.3.0",
  "contributors": [
    { "id": "alice", "role": "artist", "weight": 0.5, "notes": "Vocals and lyrics" },
    { "id": "bob", "role": "producer", "weight": 0.3, "notes": "Beat and mixing" },
    { "id": "charlie", "role": "engineer", "weight": 0.2, "notes": "Mastering" }
  ]
}
```

### Step 3: Use it

What you do with the manifest is up to you and your platform:

- **Payment splitting:** Read the weights, distribute revenue accordingly
- **Credit display:** Show contributor names and roles on your UI
- **Provenance:** Chain manifests together via `context.derivedFrom` to trace lineage
- **Automation:** CI/CD can generate manifests from git history (see [RFC-01](../rfcs/RFC-01-commit-attribution.md))

## What problems does this solve?

**Today:** You upload a song to Spotify. The metadata is locked in Spotify's database. Move to another platform? Re-enter everything. Collaborate? Email spreadsheets about who gets what percentage.

**With .fair:** The attribution travels with the file. Any platform that reads `.fair.json` knows who made it and how to split revenue. Switch platforms, the data comes with you.

**Today:** An AI service uses your dataset for training. You have no record of your contribution and no way to get compensated.

**With .fair:** Every step in the chain — dataset → training → inference → response — carries attribution. When someone pays for an AI query, the manifest says who contributed and how much they're owed.

## What .fair is NOT

- **Not a blockchain.** It's a file format. No tokens required.
- **Not a platform.** It's a standard any platform can adopt.
- **Not DRM.** It doesn't restrict access. It documents contribution.
- **Not mandatory.** Use as much or as little of the schema as you need.

## Validate your manifest

```bash
npx ajv-cli validate -s schema/fair.schema.json -d my-track.fair.json
```

## Go deeper

- [Full Specification](../spec/SPEC.md) — Complete schema reference
- [Examples](../examples/) — Sample manifests for music, events, code, AI services
- [RFC-01: Commit Attribution](../rfcs/RFC-01-commit-attribution.md) — Auto-generate from git
- [RFC-02: Runtime Modules](../rfcs/RFC-02-runtime-modules.md) — Attribution for AI/compute services
- [Architecture](./ARCHITECTURE.md) — How .fair fits into the Imajin ecosystem

## The bigger picture

`.fair` is the attribution layer in [Imajin](https://imajin.ai)'s sovereign infrastructure stack. The ecosystem adds identity ([DFOS](https://github.com/metalabel/dfos) chains), payments (Stripe today, MJN token later), and trust graphs on top — but `.fair` itself is just JSON files that say who made what and who gets paid.

With a DID, your `.fair` manifest becomes a DFOS content chain entry — signed, federated across relay nodes, verifiable by anyone. Without a DID, it's still a valid attribution file. The spec is designed to work at both levels.

You don't need Imajin to use `.fair`. You don't need a token. You don't need a DID. Start with a JSON file. Adopt more when it's useful.
