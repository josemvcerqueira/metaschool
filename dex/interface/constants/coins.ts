import { COIN_TYPE, Network } from '@interest-protocol/sui-amm-sdk';

export enum TOKEN_SYMBOL {
  ETH = 'ETH',
  USDC = 'USDC',
}

export const COINS_TYPE = {
  [Network.DEVNET]: [
    COIN_TYPE[Network.DEVNET].ETH,
    COIN_TYPE[Network.DEVNET].USDC,
  ],
  [Network.TESTNET]: [
    COIN_TYPE[Network.TESTNET].ETH,
    COIN_TYPE[Network.TESTNET].USDC,
  ],
  [Network.MAINNET]: [],
};

export const COIN_TYPE_TO_SYMBOL = {
  [Network.DEVNET]: {
    [COIN_TYPE[Network.DEVNET].ETH]: TOKEN_SYMBOL.ETH,
    [COIN_TYPE[Network.DEVNET].USDC]: TOKEN_SYMBOL.USDC,
  },
  [Network.TESTNET]: {
    [COIN_TYPE[Network.TESTNET].ETH]: TOKEN_SYMBOL.ETH,
    [COIN_TYPE[Network.TESTNET].USDC]: TOKEN_SYMBOL.USDC,
  },
  [Network.MAINNET]: {},
} as Record<Network, Record<string, TOKEN_SYMBOL>>;

export const COIN_DECIMALS = {
  [Network.DEVNET]: {
    [COIN_TYPE[Network.DEVNET].ETH]: 9,
    [COIN_TYPE[Network.DEVNET].USDC]: 9,
  },
  [Network.TESTNET]: {
    [COIN_TYPE[Network.TESTNET].ETH]: 9,
    [COIN_TYPE[Network.TESTNET].USDC]: 9,
  },
  [Network.MAINNET]: {},
};

export const COINS = {
  [Network.DEVNET]: {
    ETH: {
      decimals: COIN_DECIMALS[Network.DEVNET][COIN_TYPE[Network.DEVNET].ETH],
      symbol: TOKEN_SYMBOL.ETH,
      type: COIN_TYPE[Network.DEVNET].ETH,
    },
    USDC: {
      decimals: COIN_DECIMALS[Network.DEVNET][COIN_TYPE[Network.DEVNET].USDC],
      symbol: TOKEN_SYMBOL.USDC,
      type: COIN_TYPE[Network.DEVNET].USDC,
    },
  },
  [Network.TESTNET]: {
    ETH: {
      decimals: COIN_DECIMALS[Network.TESTNET][COIN_TYPE[Network.TESTNET].ETH],
      symbol: TOKEN_SYMBOL.ETH,
      type: COIN_TYPE[Network.TESTNET].ETH,
    },
    USDC: {
      decimals: COIN_DECIMALS[Network.TESTNET][COIN_TYPE[Network.TESTNET].USDC],
      symbol: TOKEN_SYMBOL.USDC,
      type: COIN_TYPE[Network.TESTNET].USDC,
    },
  },
  [Network.MAINNET]: {},
};
