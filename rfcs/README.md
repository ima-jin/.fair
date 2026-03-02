# .fair RFCs (Requests for Comments)

This directory contains design proposals and implementation specifications for the `.fair` attribution standard.

## Active RFCs

| RFC | Title | Status | Created | Updated |
|-----|-------|--------|---------|---------|
| [RFC-01](./RFC-01-commit-attribution.md) | Commit-Based Attribution | Draft | 2026-03-02 | 2026-03-02 |
| [RFC-02](./RFC-02-runtime-modules.md) | Runtime Module Attribution | Draft | 2026-03-02 | 2026-03-02 |
| [RFC-03](./RFC-03-memory-attribution.md) | Memory and Context Attribution | Draft | 2026-03-02 | 2026-03-02 |
| [RFC-04](./RFC-04-settlement.md) | Settlement and Payment Distribution | Draft | 2026-03-02 | 2026-03-02 |

## RFC Status Definitions

- **Draft**: Proposal under active development and discussion
- **Review**: Open for community feedback
- **Accepted**: Approved for implementation
- **Implemented**: Specification realized in code
- **Deprecated**: Superseded by newer proposal

## Submitting an RFC

1. Fork the [.fair repository](https://github.com/ima-jin/.fair)
2. Copy `rfcs/template.md` to `rfcs/RFC-XX-your-title.md`
3. Fill in the template with your proposal
4. Submit a pull request
5. Engage in discussion and iterate on feedback
6. Once consensus is reached, RFC is merged as "Accepted"

## RFC Topics

### Current Focus Areas

- **Code Attribution** — Extracting attribution from git history
- **Runtime Services** — Inference, memory, embedding, search
- **Privacy** — Zero-knowledge proofs, TEEs, HRPOS
- **Settlement** — Fiat, on-chain, local node-to-node
- **Quality Metrics** — Benchmarking and reputation

### Future Topics

- Cross-chain attribution (Ethereum, Solana, Bitcoin)
- Attribution for AI training data
- Federated .fair registries
- Dispute resolution governance
- Integration with existing standards (SPDX, PROV-O, etc.)

## Discussion

For questions and discussion:

- **GitHub Issues**: [github.com/ima-jin/.fair/issues](https://github.com/ima-jin/.fair/issues)
- **GitHub Discussions**: [github.com/ima-jin/.fair/discussions](https://github.com/ima-jin/.fair/discussions)
- **Discord**: [imajin.ai/discord](https://imajin.ai/discord)

## License

All RFCs are licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).
