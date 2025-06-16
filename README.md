# .fair

**A minimal manifest for attribution, provenance, and compensation.**

`.fair.json` is a plain-text metadata format that defines who contributed to a piece of work, how it should be attributed, and how value (if any) should be shared.

It lives alongside your content — in the same repo, folder, or object — and gives future humans and machines the context they need to use your work fairly.

---

## 🌱 Why `.fair`?

Modern creative work is collaborative, composable, and spread across platforms. `.fair.json` is a small, structured substrate that makes the invisible glue visible:

- Who made this?
- Who should be credited?
- Who gets paid?
- What license applies?
- Where did this come from?

This isn’t a license. It’s a statement of **intention, provenance, and value** — portable across systems.

---

## ✍️ Example

```json
{
  "schema": "https://ima-jin.github.io/.fair/schema/fair.schema.json",
  "version": "0.1.0",
  "title": "Desert Echoes EP",
  "license": "CC-BY-SA-4.0",
  "contributors": [
    {
      "id": "did:example:alice",
      "name": "Alice",
      "role": "composer",
      "percent": 50
    },
    {
      "id": "did:example:bob",
      "name": "Bob",
      "role": "producer",
      "percent": 50
    }
  ],
  "source": [
    "ar://abc123",
    "ipfs://xyz456"
  ],
  "tags": ["electronic", "ambient", "2025"]
}
```

---

⚙️ Validation

This repo includes a JSON Schema to validate .fair.json files.

You can use ajv-cli:

npx ajv validate -s schema/fair.schema.json -d yourfile.fair.json


---

🤝 FAIR Data Alignment

This project wasn’t based on the FAIR Data Principles — but aligns with them by design:

Findable: Uses consistent schema and tags.

Accessible: Plain JSON, versioned, human- and machine-readable.

Interoperable: Schema-defined, supports DID, CID, IPFS, etc.

Reusable: Explicit license, provenance, and contribution breakdown.


You could say this is FAIR — with teeth.


---

📡 Use Cases

Creative collectives

Open-source attribution

Dataset packaging

Licensing overlays

Tokenized compensation

Schema-tagged LLM training data



---

🛠 Roadmap

[ ] CLI tools for generating .fair.json

[ ] .fair data unions

[ ] Integration with git, Arweave, IPFS

[ ] Live registry + explorer



---

🧬 License

MIT — but the work described by .fair.json may have its own license. This format helps you declare that.


---

Follow @ima-jin for updates.
This is early substrate. If it feels drafty — that’s the point. Join the discussion.

---
