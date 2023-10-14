export const getError = (
  key?: string,
  symbol?: string | null
): string | undefined => {
  const errors: Record<string, string> = {
    amountOut: 'Failed to fetch the amount out',
    sameTokens: 'Cannot swap the same token',
    balances: 'Failed to fetch balances',
    noMarket: 'This pair has no market',
    infoNoPool: 'Increase amount or add liquidity to this pair',
    noPool: 'No pool found! Try an existing one',
    error: 'Failed: try a higher slippage or smaller amount',
    increaseAmount: `Try to increase ${symbol} amount`,
  };

  return errors[key!];
};
