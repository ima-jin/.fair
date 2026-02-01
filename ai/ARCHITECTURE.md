# Fair-Protocol Architecture: Universal Revenue Attribution

## 🏗️ Core Services Architecture

### Service Layer Overview
```
┌─────────────────────────────────────────────────────────────────────┐
│                        🌐 fair-protocol.org                        │
│                     (Standards & Registry)                         │
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │   .fair Schema  │  │   Server        │  │   Manifest      │    │
│  │   Validation    │  │   Discovery     │  │   Registry      │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    ▼             ▼             ▼
```

```
┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│   fair-distributions │  │     fair-wallet      │  │    fair-servers      │
│   (Revenue Engine)   │  │   (Payment Rails)    │  │   (Self-Hosted)      │
│                      │  │                      │  │                      │
│  ┌────────────────┐  │  │  ┌────────────────┐  │  │  ┌────────────────┐  │
│  │ .fair Manifest │  │  │  │ Multi-Currency │  │  │  │ Private Cloud  │  │
│  │ Processing     │  │  │  │ Wallets        │  │  │  │ Deployment     │  │
│  └────────────────┘  │  │  └────────────────┘  │  │  └────────────────┘  │
│  ┌────────────────┐  │  │  ┌────────────────┐  │  │  ┌────────────────┐  │
│  │ Temporal Splits│  │  │  │ Payment        │  │  │  │ Custom         │  │
│  │ & Conditions   │  │  │  │ Processors     │  │  │  │ Integrations   │  │
│  └────────────────┘  │  │  └────────────────┘  │  │  └────────────────┘  │
│  ┌────────────────┐  │  │  ┌────────────────┐  │  │  ┌────────────────┐  │
│  │ Batch          │  │  │  │ Batch Payouts  │  │  │  │ Organization   │  │
│  │ Calculations   │  │  │  │ & Settlements  │  │  │  │ Control        │  │
│  └────────────────┘  │  │  └────────────────┘  │  │  └────────────────┘  │
│                      │  │                      │  │                      │
│ distribution.fair.io │  │   wallet.fair.io     │  │  your-org.fair.io    │
└──────────────────────┘  └──────────────────────┘  └──────────────────────┘
```

## 📊 Data Flow Architecture

### CLI → Distribution → Wallet Pipeline
```
┌─────────────────────────────────────────────────────────────────────┐
│                     Generated CLIs (Edge)                          │
│                                                                     │
│  stripe-cli ──┐                                                    │
│  notion-cli ──┼─── Usage Reports ──▶ distribution.fair.io         │
│  slack-cli  ──┘    (Every hour)                                    │
│                                                                     │
│  Customer's Infrastructure                                          │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  🤖 fair-distributions Service                     │
│                      (Revenue Calculation)                         │
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │   CLI Usage     │  │   Batch         │  │   .fair         │    │
│  │   Aggregation   │─▶│   Processing    │─▶│   Manifest      │    │
│  │   (Hourly)      │  │   (Daily)       │  │   Validation    │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
│                                                                     │
│  Hosted Service: distribution.fair.io                             │
└─────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  💰 fair-wallet Service                            │
│                   (Universal Payment Rails)                        │
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │   Multi-Modal   │  │   Batch         │  │   Cross-Domain  │    │
│  │   Revenue       │  │   Processing    │  │   Payouts       │    │
│  │   (All Sources) │  │   (Monthly)     │  │   (Unified)     │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
│                                                                     │
│  Enhanced Service: wallet.fair.io                                 │
└─────────────────────────────────────────────────────────────────────┘
```

## 🛠️ Service Specifications

### 1. fair-distributions (Revenue Calculation Engine)

```typescript
interface DistributionService {
  // Core functionality
  calculateRevenueSplits(manifest: FairManifest, revenue: Revenue): Split[]
  processTemporalConditions(splits: Split[], currentConditions: Conditions): Split[]
  batchCalculations(distributions: Distribution[]): BatchedDistribution[]
  
  // Integration points
  validateManifest(manifest: FairManifest): ValidationResult
  trackRevenueSource(source: RevenueSource): void
  generateDistributionReport(period: TimePeriod): DistributionReport
}

// Example usage patterns
const distributionService = new DistributionService({
  manifestRegistry: 'https://manifests.fair.io',
  walletService: 'https://wallet.fair.io'
})

// CLI usage revenue
await distributionService.processRevenue({
  manifestId: 'urn:fair:cli:stripe-cli-v1.2.0',
  revenue: { amount: 1500, currency: 'USD', source: 'api_calls' },
  period: { start: '2025-01-01', end: '2025-01-31' }
})

// Music streaming revenue  
await distributionService.processRevenue({
  manifestId: 'urn:fair:track:summer-beats-2024',
  revenue: { amount: 5000, currency: 'USD', source: 'streaming' },
  period: { start: '2025-01-01', end: '2025-01-31' }
})

// Event ticket sales
await distributionService.processRevenue({
  manifestId: 'urn:fair:event:summer-festival-2025',
  revenue: { amount: 25000, currency: 'USD', source: 'ticket_sales' },
  period: { start: '2025-08-15', end: '2025-08-15' }
})
```

### 2. fair-wallet (Universal Payment Rails)

```typescript
interface WalletService {
  // Wallet management
  createWallet(config: WalletConfig): Wallet
  getWalletBalance(walletId: string, currency?: string): Balance
  transferFunds(from: string, to: string, amount: Money): Transaction
  
  // Batch operations
  executeBatchPayouts(payouts: Payout[]): BatchResult
  scheduleRecurringPayouts(schedule: PayoutSchedule): void
  
  // Multi-currency & payment processors
  addPaymentProcessor(processor: PaymentProcessor): void
  convertCurrency(amount: Money, targetCurrency: string): Money
  
  // .fair integration
  processDistributionResult(result: DistributionResult): void
  validateAttributionChain(walletId: string): AttributionValidation
}

// Example: Multi-modal payouts
const walletService = new WalletService({
  paymentProcessors: [
    new StripeProcessor({ apiKey: process.env.STRIPE_KEY }),
    new EthereumProcessor({ rpcUrl: process.env.ETH_RPC }),
    new BankTransferProcessor({ bankingApi: process.env.BANKING_API })
  ]
})

// Single monthly payout combining multiple revenue streams
await walletService.executeBatchPayouts([
  {
    walletId: 'did:ethr:0xCreatorWallet',
    totalAmount: { amount: 847.50, currency: 'USD' },
    sources: [
      { type: 'music_streaming', amount: 245.20 },
      { type: 'cli_usage', amount: 432.10 },
      { type: 'event_revenue', amount: 170.20 }
    ],
    paymentMethod: 'stripe_direct_deposit'
  }
])
```

### 3. fair-servers (Self-Hosted Infrastructure)

```yaml
# docker-compose.yml for self-hosted fair-server
version: '3.8'
services:
  fair-distributions:
    image: fair/distributions:latest
    environment:
      - MANIFEST_REGISTRY_URL=https://your-org.fair.io/manifests
      - WALLET_SERVICE_URL=https://your-org.fair.io/wallet
      - DATABASE_URL=postgres://user:pass@postgres:5432/fair_distributions
    
  fair-wallet:
    image: fair/wallet:latest
    environment:
      - PAYMENT_PROCESSORS=stripe,bank_transfer,internal_ledger
      - DISTRIBUTION_SERVICE_URL=https://your-org.fair.io/distributions
      - DATABASE_URL=postgres://user:pass@postgres:5432/fair_wallet
      
  fair-manifests:
    image: fair/manifest-registry:latest
    environment:
      - STORAGE_BACKEND=s3,ipfs,local
      - VALIDATION_SERVICE_URL=https://manifests.fair.io/validate
      
  fair-dashboard:
    image: fair/dashboard:latest
    environment:
      - SERVICES_BASE_URL=https://your-org.fair.io
      - AUTH_PROVIDER=auth0,clerk,custom
```

## 🔗 Integration with Existing Systems

### imajin-cli Integration
```typescript
// Embedded in every generated CLI
class UsageTracker {
  private usageLog: UsageRecord[] = []
  
  async trackApiCall(endpoint: string, cost: number) {
    this.usageLog.push({
      timestamp: new Date(),
      endpoint,
      cost,
      fairAttribution: this.fairManifest.id
    })
    
    // Report to distribution service every hour
    if (this.shouldReport()) {
      await this.reportUsage()
    }
  }
  
  private async reportUsage() {
    await fetch('https://distribution.fair.io/usage', {
      method: 'POST',
      body: JSON.stringify({
        cliId: this.fairManifest.id,
        usage: this.usageLog,
        customerWallet: process.env.CUSTOMER_WALLET_ID
      })
    })
    this.usageLog = [] // Clear after reporting
  }
}
```

### WeR1 Pattern Integration
```typescript
// Enhanced wer1-graph service
class UnifiedWalletService extends DistributionService {
  async processUnifiedDistributions() {
    // Process existing WeR1 music revenue
    const musicRevenue = await this.processMusicDistributions()
    
    // Process new CLI revenue from fair-distributions
    const cliRevenue = await this.processCliDistributions()
    
    // Combine and batch by wallet
    const combinedPayouts = this.combinePayouts(musicRevenue, cliRevenue)
    
    // Single payout per user per month
    await this.executeMonthlyPayouts(combinedPayouts)
  }
  
  private combinePayouts(musicRevenue: Payout[], cliRevenue: Payout[]) {
    const walletMap = new Map<string, CombinedPayout>()
    
    // Combine payouts by wallet ID
    [...musicRevenue, ...cliRevenue].forEach(payout => {
      const existing = walletMap.get(payout.walletId) || {
        walletId: payout.walletId,
        totalAmount: 0,
        sources: []
      }
      
      existing.totalAmount += payout.amount
      existing.sources.push({
        type: payout.source, // 'music_streams' or 'cli_usage'
        amount: payout.amount,
        details: payout.metadata
      })
      
      walletMap.set(payout.walletId, existing)
    })
    
    return Array.from(walletMap.values())
  }
}
```

## 🌐 Federation & Cross-Server Attribution

### Cross-Server Manifest Example
```json
{
  "id": "urn:fair:collaboration:cross-org-project",
  "contributors": [
    {
      "actor": { 
        "id": "did:ethr:0xMusicianWallet", 
        "fairServer": "https://music-coop.fair.io" 
      },
      "role": "artist",
      "weight": 0.6
    },
    {
      "actor": { 
        "id": "did:ethr:0xDeveloperWallet", 
        "fairServer": "https://tech-collective.fair.io" 
      },
      "role": "developer", 
      "weight": 0.4
    }
  ],
  "distribution_config": {
    "settlement_network": "fair-protocol",
    "cross_server_fees": 0.01,
    "settlement_frequency": "monthly"
  }
}
```

### Revenue Processing Flow
```typescript
class FairDistributionEngine {
  async processRevenue(revenue: Revenue, manifest: FairManifest) {
    // 1. Calculate manifest-specific splits
    const manifestSplits = this.calculateManifestSplits(revenue, manifest)
    
    // 2. Add infrastructure attribution
    const infrastructureFee = revenue.amount * 0.02 // 2% to foundation patterns
    const wer1Attribution = infrastructureFee * 0.25 // WeR1's 25% of infrastructure
    
    // 3. Process all distributions
    await this.distributeRevenue([
      ...manifestSplits,
      {
        walletId: 'did:ethr:0xWeR1Protocol',
        amount: wer1Attribution,
        source: 'infrastructure_pattern_attribution',
        metadata: {
          pattern: 'wallet_distribution_architecture',
          revenue_source: revenue.source
        }
      }
    ])
  }
}
```

## 🎯 Scalability & Performance

### Horizontal Scaling
- **CLIs are stateless**: Report usage, don't handle payments
- **Batched processing**: Efficient handling of millions of API calls
- **Distributed load**: Multiple CLIs report independently
- **Regional deployment**: fair-servers can be deployed globally

### Reliability
- **Retry logic**: CLIs retry failed usage reports
- **Graceful degradation**: CLIs work even if reporting fails
- **Audit trail**: Complete transaction history
- **Multi-server redundancy**: Federation provides fault tolerance

### Economic Efficiency
- **Batch payments**: Reduce transaction fees
- **Smart batching**: Group small payments to meet thresholds
- **Multi-currency**: Handle different currencies efficiently
- **Cross-server settlement**: Minimize inter-server transfers 