import { Box, Button } from '@interest-protocol/ui-kit';
import { FC, useEffect } from 'react';

import {
  beginZKLogin,
  completeZkLogin,
} from '@/components/zk-login/zk-login.utils';
import { useSuiClient, useWeb3 } from '@/hooks';
import { SignOutSVG } from '@/svg';

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
    <Box display="flex" gap="l">
      {account ? (
        <>
          <Button size="small" variant="outline" disabled>
            {account.userAddr.slice(0, 6)}...{account.userAddr.slice(-5)}
          </Button>
          <Button variant="icon" disabled color="error">
            <SignOutSVG maxHeight="1rem" maxWidth="1rem" width="100%" />
          </Button>
        </>
      ) : (
        <Button
          size="small"
          variant="filled"
          onClick={() => beginZKLogin(suiClient, 'Google')}
        >
          Sign with Google
        </Button>
      )}
    </Box>
  );
};

export default ZKLogin;
