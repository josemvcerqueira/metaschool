import { COIN_TYPE, Network } from '@interest-protocol/sui-amm-sdk';

export const BASE_TOKENS_TYPES = {
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
