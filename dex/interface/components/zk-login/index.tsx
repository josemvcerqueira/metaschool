import { Box, Button } from '@interest-protocol/ui-kit';
import { FC } from 'react';

import {
  beginZKLogin,
  clearSetupData,
} from '@/components/zk-login/zk-login.utils';
import { useSuiClient, useWeb3 } from '@/hooks';
import { SignOutSVG } from '@/svg';

import {} from './zk-login.utils';

const ZKLogin: FC = () => {
  const suiClient = useSuiClient();
  const { account, setAccount } = useWeb3();

  return (
    <Box display="flex" gap="l">
      {account ? (
        <>
          <Button size="small" variant="outline" disabled>
            {account.userAddr.slice(0, 6)}...{account.userAddr.slice(-5)}
          </Button>
          <Button
            variant="icon"
            color="error"
            onClick={async () => {
              clearSetupData();
              setAccount(null);
            }}
          >
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
