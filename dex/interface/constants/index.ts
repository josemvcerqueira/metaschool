import { COIN_TYPE, Network } from '@interest-protocol/sui-amm-sdk';

import { ETHSVG, UnknownCoinSVG, USDCSVG } from '@/svg';
export * from './coins';
export * from './dex';

export const MAX_NUMBER_INPUT_VALUE = 9000000000000000;

export const EXPLORER_URL = {
  [Network.MAINNET]: 'https://suivision.xyz',
  [Network.TESTNET]: 'https://testnet.suivision.xyz',
  [Network.DEVNET]: '',
};

export const TOKENS_SVG_MAP_V2 = {
  default: UnknownCoinSVG,
  [COIN_TYPE[Network.TESTNET].ETH]: ETHSVG,
  [COIN_TYPE[Network.TESTNET].USDC]: USDCSVG,
};

export const TOAST_DURATION = 10000;
