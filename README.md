# Chronicle Oracle Settlement Protocol

![Banner](assets/banner.svg)

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?logo=solidity)](https://soliditylang.org/)
[![Oracles](https://img.shields.io/badge/Oracles-Chainlink%20%7C%20Pyth-64ffda)](https://chain.link)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.5-3178C6?logo=typescript)](https://www.typescriptlang.org/)

> **A resilient multi-source Oracle price aggregator and anti-flash-loan settlement protocol on EVM.**

---

## 🌟 Overview

Decentralized lending, perp DEXs, and structured product protocols are highly vulnerable to single-source oracle manipulation and flash loan price skewing.

**Chronicle Oracle Settlement** guarantees:
- **Cross-Feed Deviation Bounds**: Strictly cross-references primary (e.g. Chainlink) and secondary (e.g. Pyth / Redstone) feeds; reverts if deviation exceeds threshold (default 500 bps / 5%).
- **Staleness Heartbeat Checks**: Guarantees round timestamps are within acceptable maximum age windows.
- **Client-Side Deviation Auditor**: TypeScript module for real-time price monitoring and anomaly detection.

---

## 🚀 Quick Start

```bash
npm install
npm run test
npm run build
```

---

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.