# RFC-04: Settlement and Payment Distribution

**Status**: Draft
**Author**: Imajin Team
**Created**: 2026-03-02
**Updated**: 2026-03-02

## Abstract

This RFC defines the settlement layer for `.fair` attribution manifests, covering how contributors receive payment across multiple payment rails: fiat (Stripe), on-chain (Solana/MJN), and local node-to-node settlement.

## Motivation

Attribution without **settlement** is incomplete. Contributors need:

1. **Automated payouts** — No manual invoicing or payment tracking
2. **Low transaction costs** — Micro-payments shouldn't be eaten by fees
3. **Multiple currencies** — Fiat, stablecoins, protocol tokens
4. **Cross-border support** — Global contributor base
5. **Privacy** — Optional anonymity for contributors
6. **Dispute resolution** — Mechanisms for contesting splits

## Proposal

### Three-Phase Rollout

#### Phase 1: Fiat Settlement (Stripe)

**Timeline**: 2026 Q2

**Mechanism**:
- Batched payouts (daily, weekly, monthly)
- Minimum payout thresholds to reduce fees
- Traditional banking integration via Stripe Connect

**Example configuration**:

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

**Workflow**:

1. User pays $5.00 for a query
2. Attribution split:
   - Memory (Alice): $1.00
   - Inference (Bob): $3.00
   - Protocol: $1.00
3. Charges accumulate in escrow
4. Every Monday, balances above $10 trigger payouts
5. Stripe transfers funds to linked bank accounts

**Fees**:
- Stripe charges ~2.9% + $0.30 per transaction
- Batching reduces per-transaction overhead

**Pros**:
- Easy fiat on/off ramp
- Regulatory compliant (KYC/AML via Stripe)
- Familiar for traditional contractors

**Cons**:
- High fees for small amounts
- Requires bank account
- Centralized (Stripe dependency)

#### Phase 2: On-Chain Settlement (Solana/MJN)

**Timeline**: 2026 Q4

**Mechanism**:
- Per-transaction settlement on Solana blockchain
- MJN token as native settlement currency
- Smart contract handles automatic distribution

**Example configuration**:

```json
{
  "metadata": {
    "settlement": {
      "method": "solana",
      "token": "MJN",
      "wallets": {
        "did:imajin:alice": "ALICEabc123...",
        "did:imajin:bob": "BOBxyz789...",
        "mjn:protocol": "PROTOCOLdef456..."
      }
    }
  }
}
```

**Workflow**:

1. User pays 0.5 MJN for a query
2. Smart contract splits:
   - Alice: 0.1 MJN
   - Bob: 0.3 MJN
   - Protocol: 0.1 MJN
3. Instant on-chain transfer (< 1 second finality)

**Fees**:
- Solana transaction fee: ~$0.00025 per split
- Negligible for most transactions

**Pros**:
- Near-instant settlement
- Low fees enable micro-transactions
- Transparent, auditable on-chain
- Permissionless (no Stripe account required)

**Cons**:
- Requires crypto wallet
- Price volatility (MJN/USD exchange rate)
- Regulatory uncertainty in some jurisdictions

#### Phase 3: Local Node-to-Node Settlement

**Timeline**: 2027+

**Mechanism**:
- Direct peer-to-peer settlement between trusted nodes
- Offline capability with eventual reconciliation
- Credit lines based on trust graph

**Example configuration**:

```json
{
  "metadata": {
    "settlement": {
      "method": "local",
      "protocol": "imajin-settlement-v1",
      "trustGraph": {
        "creditLineUSD": 1000,
        "settlementPeriod": "monthly"
      }
    }
  }
}
```

**Workflow**:

1. Alice and Bob are mutually trusted nodes (trust score > 0.8)
2. Alice uses Bob's inference service
3. Attribution recorded locally, no immediate payment
4. At end of month, balances reconciled:
   - Alice owes Bob $120
   - Bob owes Alice $80 (for memory retrieval)
   - Net settlement: Alice pays Bob $40
5. Payment via preferred method (Stripe, crypto, or local transfer)

**Pros**:
- Works offline or in low-connectivity environments
- Minimal transaction overhead
- Flexible payment methods

**Cons**:
- Requires mutual trust (not suitable for strangers)
- Complex reconciliation logic
- Risk of non-payment (mitigated by credit limits)

### Settlement Metadata Schema

All `.fair` manifests should include settlement metadata:

```json
{
  "metadata": {
    "settlement": {
      "method": "stripe" | "solana" | "local",
      "currency": "USD" | "MJN" | "SOL" | "USDC",
      "batchingPeriod": "daily" | "weekly" | "monthly" | "instant",
      "minimumPayout": number,
      "accounts": {
        "did:contributor": "account-id"
      },
      "escrowAddress": "string",
      "lastSettlement": "ISO-8601 timestamp",
      "nextSettlement": "ISO-8601 timestamp"
    }
  }
}
```

### Minimum Payout Thresholds

To prevent dust accumulation:

| Method | Minimum Payout | Batching Period |
|--------|----------------|-----------------|
| Stripe | $10.00         | Weekly          |
| Solana | $0.10          | Instant         |
| Local  | Negotiated     | Monthly         |

Contributors with balances below threshold carry over to next period.

### Escrow and Trust

**Problem**: User pays upfront, but services are rendered over time. Who holds funds?

**Options**:

1. **Protocol Escrow** (Recommended)
   - User deposits funds into protocol-controlled escrow
   - Funds released to contributors upon query completion
   - Disputes handled by protocol governance

2. **Smart Contract Escrow** (Phase 2)
   - Funds locked in smart contract
   - Automatic release upon cryptographic proof of service
   - Immutable, trustless

3. **Third-Party Escrow** (Phase 1)
   - Stripe holds funds temporarily
   - Released after 24-hour dispute window

### Dispute Resolution

**Scenario**: User contests a charge, claiming poor service quality.

**Process**:

1. User files dispute within 24 hours of transaction
2. Attribution manifest frozen (no payouts)
3. Evidence submitted:
   - User: Query logs, response quality
   - Contributor: Service logs, SLA compliance
4. Resolution:
   - **Automated**: SLA breach detected → partial refund
   - **Manual**: Protocol governance votes (if automated fails)
5. Outcome:
   - Full refund → no attribution payout
   - Partial refund → reduced attribution weights
   - Dispute rejected → original attribution stands

**Open questions**:
- Who bears cost of dispute resolution?
- How to prevent frivolous disputes?
- Decentralized governance vs. centralized arbitration?

### Cross-Border and Tax Compliance

**Problem**: Contributors are global. Tax jurisdictions vary.

**Phase 1 (Stripe)**:
- Stripe handles 1099/W9 forms (US)
- Contributors responsible for local tax compliance
- Annual tax statements provided

**Phase 2 (On-Chain)**:
- No automatic tax reporting
- Contributors self-report crypto income
- Protocol may provide transaction history exports

**Phase 3 (Local)**:
- Bilateral agreements between nodes
- Tax treatment varies by jurisdiction

**Regulatory considerations**:
- Some jurisdictions require KYC for payouts > $X
- Crypto payments may be restricted in some countries
- Cross-border payments subject to SWIFT/AML rules

### Failed Payments and Unclaimed Funds

**Scenario**: Contributor's payment account is invalid or inaccessible.

**Handling**:

1. Retry payment 3 times over 7 days
2. If failed, hold funds in escrow
3. Notify contributor via DID-linked communication channel
4. After 90 days, funds revert to protocol treasury
5. Contributor can reclaim within 1 year

**Unclaimed funds policy**:
- Year 1: Full claim available
- Year 2: 50% claim (50% to protocol treasury)
- Year 3+: Funds fully absorbed by protocol

### Privacy and Anonymity

**Question**: Can contributors remain anonymous while receiving payment?

**Phase 1 (Stripe)**: No — KYC required for bank transfers

**Phase 2 (On-Chain)**: Yes — Pseudonymous wallet addresses

**Phase 3 (Local)**: Depends on trust relationship

**Privacy-preserving options**:
- Use privacy-focused chains (Zcash, Monero) for settlement
- Mixer services (legal in some jurisdictions)
- Anonymous DID schemes (did:key)

**Trade-offs**:
- Anonymity vs. regulatory compliance
- Anonymity vs. dispute resolution (harder to verify identity)

## Open Questions

1. **Exchange Rate Risk**
   - If user pays in USD but contributor receives MJN, who bears volatility risk?
   - Should protocol offer hedging or stablecoin conversion?

2. **Multi-Hop Attribution**
   - If query A triggers query B (cascade), how to aggregate settlement?
   - Nested attribution manifests? Single flattened manifest?

3. **Retroactive Attribution**
   - If attribution weights are contested and revised, how to handle past payouts?
   - Clawback mechanisms? Forward-only adjustments?

4. **Micropayment Aggregation**
   - If user makes 1000 queries at $0.001 each, settle individually or batch?
   - Lightning Network integration for Bitcoin?

5. **Multi-Party Disputes**
   - If 5 contributors involved in a query, and user disputes only 1, how to resolve?
   - Partial freezes? Full freeze?

6. **Decentralized Governance**
   - Who controls dispute resolution in Phase 2+?
   - Token-weighted voting? Reputation-weighted? Democracy?

## Implementation Checklist

- [ ] Stripe Connect integration (Phase 1)
- [ ] Batching and minimum payout logic
- [ ] Solana smart contract for splits (Phase 2)
- [ ] MJN token minting and distribution
- [ ] Local settlement reconciliation protocol (Phase 3)
- [ ] Dispute filing and resolution workflow
- [ ] Tax reporting exports
- [ ] Failed payment retry logic
- [ ] Unclaimed funds escrow management

## Prior Art

- **Stripe Connect** — Multi-party payment splitting
- **Coinbase Commerce** — Crypto payment processing
- **Lightning Network** — Bitcoin micropayments
- **Raiden Network** — Ethereum state channels for micropayments
- **OpenCollective** — Transparent fund management for open-source projects

## References

- [.fair Specification v0.3](../spec/SPEC.md)
- [RFC-02: Runtime Modules](./RFC-02-runtime-modules.md)
- [Stripe Connect Documentation](https://stripe.com/docs/connect)
- [Solana Program Library: Token Program](https://spl.solana.com/token)

## Changelog

- **2026-03-02**: Initial draft
