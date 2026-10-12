import { describe, it, expect } from 'vitest';
import { OracleDeviationChecker } from '../src/deviation.js';

describe('OracleDeviationChecker', () => {
  it('accurately computes basis points deviation between oracle feeds', () => {
    const priceA = 3000_00000000n; // 3000 USD
    const priceB = 3030_00000000n; // 3030 USD (+1%)
    const deviationBps = OracleDeviationChecker.calculateDeviationBps(priceA, priceB);
    expect(deviationBps).toBe(100); // 100 bps = 1.00%
  });

  it('flags stale oracle timestamps exceeding threshold', () => {
    const now = 1718005000;
    const fresh = now - 300; // 5 min ago
    const stale = now - 4000; // > 1 hour ago

    expect(OracleDeviationChecker.isFeedStale(fresh, now, 3600)).toBe(false);
    expect(OracleDeviationChecker.isFeedStale(stale, now, 3600)).toBe(true);
  });
});
