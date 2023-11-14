import { TransactionBlock } from '@mysten/sui.js/client';

import { CoinsMap } from '@/components/web3-manager/web3-manager.types';

export interface CreateVectorParameterArgs {
  txb: TransactionBlock;
  coinsMap: CoinsMap;
  type: string;
  amount: string;
}
