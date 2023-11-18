import { createContext, FC, useEffect, useMemo } from 'react';
import useSWR from 'swr';
import { useReadLocalStorage } from 'usehooks-ts';

import {
  completeZkLogin,
  loadAccount,
} from '@/components/zk-login/zk-login.utils';
import { useSuiClient } from '@/hooks';
import { LocalTokenMetadataRecord } from '@/interface';
import { makeSWRKey, noop } from '@/utils';

import { Web3ManagerProps, Web3ManagerState } from './web3-manager.types';
import { getAllCoins, parseCoins } from './web3-manager.utils';

const CONTEXT_DEFAULT_STATE = {
  account: null,
  address: null,
  coins: [],
  coinsMap: {},
  connected: false,
  error: false,
  mutate: noop,
  isFetchingCoinBalances: false,
};

export const Web3ManagerContext = createContext<Web3ManagerState>(
  CONTEXT_DEFAULT_STATE
);

const Web3Manager: FC<Web3ManagerProps> = ({ children }) => {
  const suiClient = useSuiClient();
  const account = loadAccount();

  const { data, error, mutate, isLoading } = useSWR(
    makeSWRKey([account, account?.userAddr], suiClient.getAllCoins.name),
    async () => {
      if (!account?.userAddr) return;
      return getAllCoins({ suiClient, account: account.userAddr });
    },
    {
      revalidateOnFocus: false,
      revalidateOnMount: true,
      refreshWhenHidden: false,
      refreshInterval: 10000,
    }
  );

  const tokensMetadataRecord = useReadLocalStorage<LocalTokenMetadataRecord>(
    `metaschool-tokens-metadata`
  );

  const [coins, coinsMap] = useMemo(
    () => parseCoins({ data, localTokens: tokensMetadataRecord ?? {} }),
    [data, tokensMetadataRecord, account?.userAddr, isLoading]
  );

  useEffect(() => {
    (async () => {
      await completeZkLogin();
    })()
      .catch(console.warn)
      .finally(() => mutate().catch(console.warn));
  }, []);

  return (
    <Web3ManagerContext.Provider
      value={{
        address: account?.userAddr || null,
        account: account || null,
        error: !!error,
        connected: !!account,
        coins,
        coinsMap,
        mutate,
        isFetchingCoinBalances: isLoading,
      }}
    >
      {children}
    </Web3ManagerContext.Provider>
  );
};

export default Web3Manager;
