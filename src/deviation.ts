export interface PriceFeedInput {
  price: bigint;
  updatedAt: number;
}

export class OracleDeviationChecker {
  public static calculateDeviationBps(priceA: bigint, priceB: bigint): number {
    if (priceA === 0n) return 0;
    const diff = priceA > priceB ? priceA - priceB : priceB - priceA;
    return Number((diff * 10000n) / priceA);
  }

  public static isFeedStale(updatedAt: number, currentTimestamp: number, maxSeconds = 3600): boolean {
    return currentTimestamp - updatedAt > maxSeconds;
  }
}
