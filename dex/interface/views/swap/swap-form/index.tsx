import { Box, Button, Theme, useTheme } from '@interest-protocol/ui-kit';
import { FC } from 'react';

import { DownArrowSVG } from '@/svg';

import { SwapFieldProps, SwapFormProps } from '../swap.types';
import SwapFormButton from './swap-button';
import SwapFormField from './swap-form-field';

const SwapFields: FC<SwapFieldProps> = ({ setValue, getValues }) => {
  const { dark } = useTheme() as Theme;

  const handleClick = () => {
    const { to, from } = getValues();

    setValue('from', { ...to, value: '0' });
    setValue('to', { ...from, value: '0' });
  };

  return (
    <Box display="flex" justifyContent="center">
      <Button
        variant="icon"
        cursor="pointer"
        borderRadius="m"
        border="1px solid"
        alignItems="center"
        display="inline-flex"
        onClick={handleClick}
        justifyContent="center"
        color={dark ? 'textSoft' : 'text'}
        borderColor={dark ? 'textAccent' : '#757680'}
      >
        <DownArrowSVG maxWidth="1rem" maxHeight="1rem" width="100%" />
      </Button>
    </Box>
  );
};

const SwapForm: FC<SwapFormProps> = ({
  // mutate,
  formSwap,
}) => {
  // const [toastState, setToastState] = useState<boolean>(false);

  return (
    <Box mx="auto" width="100%" gridColumn="1/-1" maxWidth="35.25rem">
      <SwapFormField name="from" formSwap={formSwap} />
      <SwapFields setValue={formSwap.setValue} getValues={formSwap.getValues} />
      <SwapFormField name="to" formSwap={formSwap} />
      <SwapFormButton formSwap={formSwap} />
    </Box>
  );
};

export default SwapForm;
