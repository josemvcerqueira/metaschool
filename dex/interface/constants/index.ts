import { FC, ReactComponentElement } from 'react';

import { SVGProps } from '@/components/svg/svg.types';
import { ETHSVG, UnknownCoinSVG, USDCSVG } from '@/svg';

export const MAX_NUMBER_INPUT_VALUE = 9000000000000000;

export enum Network {
  DEVNET = 'sui:devnet',
  TESTNET = 'sui:testnet',
  MAINNET = 'sui:mainnet',
}

export const METASCHOOL_SET_UP_KEY = 'metaschool-dex-demo.setup';
export const METASCHOOL_ACCOUNT_KEY = 'metaschool-dex-demo.accounts';

export const MAX_EPOCH = 2; // keep ephemeral keys active for this many Sui epochs from now (1 epoch ~= 24h)

export const EXPLORER_URL = {
  [Network.MAINNET]: 'https://suivision.xyz',
  [Network.TESTNET]: 'https://testnet.suivision.xyz',
  [Network.DEVNET]: '',
};

export const ETH_TYPE = 'eth';
export const USDC_TYPE = 'usdc';

export const DEX_COIN_TYPE = 'dex';

export const TOKENS_SVG_MAP_V2 = {
  default: UnknownCoinSVG,
  [ETH_TYPE]: ETHSVG,
  [USDC_TYPE]: USDCSVG,
} as Record<string, FC<SVGProps & { filled?: boolean }>>;

export const TOAST_DURATION = 10000;

export const COIN_TYPE_TO_SYMBOL = {
  [ETH_TYPE]: 'ETH',
  [USDC_TYPE]: 'USDC',
  [DEX_COIN_TYPE]: 'DEX',
} as Record<string, string>;

export const COIN_DECIMALS = {
  [ETH_TYPE]: 9,
  [USDC_TYPE]: 9,
  [DEX_COIN_TYPE]: 9,
};
