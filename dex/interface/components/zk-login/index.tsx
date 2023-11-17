import { getFaucetHost, requestSuiFromFaucetV1 } from '@mysten/sui.js/faucet';
import { FC, useEffect } from 'react';

import {
  beginZKLogin,
  completeZkLogin,
} from '@/components/zk-login/zk-login.utils';
import { useSuiClient, useWeb3 } from '@/hooks';

const ZKLogin: FC = () => {
  const suiClient = useSuiClient();
  const { mutate, account } = useWeb3();

  useEffect(() => {
    (async () => {
      await completeZkLogin();
    })()
      .catch(console.warn)
      .finally(() => mutate().catch(console.warn));
  }, []);

  return (
    <div>
      {account ? (
        <div>{account.userAddr}</div>
      ) : (
        <button onClick={() => beginZKLogin(suiClient, 'Google')}>
          Google stuff
        </button>
      )}
      <button
        disabled={!account}
        onClick={async () => {
          if (account)
            await requestSuiFromFaucetV1({
              host: getFaucetHost('devnet'),
              recipient: account.userAddr,
            });
        }}
      >
        Faucetsui
      </button>
    </div>
  );
};

export default ZKLogin;
