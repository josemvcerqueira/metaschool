import {
  COIN_TYPE,
  Network,
  OBJECT_RECORD,
} from '@interest-protocol/sui-amm-sdk';

/**
 @desc The faucet is never rendered on the Mainnet so the values are {}
*/
export const COIN_MINT_AMOUNT: Record<Network, Record<string, string>> = {
  [Network.DEVNET]: {
    [COIN_TYPE[Network.DEVNET].ETH]: '5000000000',
    [COIN_TYPE[Network.DEVNET].USDC]: '1000000000000',
  },
  [Network.TESTNET]: {
    [COIN_TYPE[Network.TESTNET].ETH]: '5000000000',
    [COIN_TYPE[Network.TESTNET].USDC]: '1000000000000',
  },
  [Network.MAINNET]: {},
};

export const COIN_TYPE_TO_CORE_NAME: Record<Network, Record<string, string>> = {
  [Network.DEVNET]: {
    [COIN_TYPE[Network.DEVNET].ETH]: 'ieth',
    [COIN_TYPE[Network.DEVNET].USDC]: 'iusdc',
  },
  [Network.TESTNET]: {
    [COIN_TYPE[Network.TESTNET].ETH]: 'ieth',
    [COIN_TYPE[Network.TESTNET].USDC]: 'iusdc',
  },
  [Network.MAINNET]: {},
};

export const COIN_TYPE_TO_STORAGE: Record<Network, Record<string, string>> = {
  [Network.DEVNET]: {
    [COIN_TYPE[Network.DEVNET].ETH]:
      OBJECT_RECORD[Network.DEVNET].FAUCET_ETH_STORAGE,
    [COIN_TYPE[Network.DEVNET].USDC]:
      OBJECT_RECORD[Network.DEVNET].FAUCET_USDC_STORAGE,
  },

  [Network.TESTNET]: {
    [COIN_TYPE[Network.TESTNET].ETH]:
      OBJECT_RECORD[Network.TESTNET].FAUCET_ETH_STORAGE,
    [COIN_TYPE[Network.TESTNET].USDC]:
      OBJECT_RECORD[Network.TESTNET].FAUCET_USDC_STORAGE,
  },
  [Network.MAINNET]: {},
};
