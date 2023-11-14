import { Box, Button } from '@interest-protocol/ui-kit';
import { FC } from 'react';
import { v4 } from 'uuid';

const Orderbook: FC = () => (
  <Box
    gap="2xs"
    width="25rem"
    display="flex"
    borderRadius="m"
    overflow="hidden"
    flexDirection="column"
  >
    <Box
      p="m"
      display="flex"
      alignItems="center"
      bg="surface.container"
      justifyContent="space-between"
    >
      <Box>Orderbook</Box>
      <Button variant="filled" size="small" px="s" py="xs" fontSize="small">
        Refresh
      </Button>
    </Box>
    <Box
      p="m"
      key={v4()}
      fontSize="s"
      display="grid"
      textAlign="center"
      bg="surface.lowestContainer"
      gridTemplateColumns="1fr 1fr 1fr"
    >
      <Box>Price</Box>
      <Box>USDC</Box>
      <Box>ETH</Box>
    </Box>
    {Array.from({ length: 3 }).map(() => (
      <Box
        p="m"
        key={v4()}
        fontSize="s"
        display="grid"
        textAlign="center"
        bg="surface.containerHighest"
        gridTemplateColumns="1fr 1fr 1fr"
      >
        <Box>100</Box>
        <Box>2000</Box>
        <Box>34</Box>
      </Box>
    ))}
    <Box
      p="m"
      key={v4()}
      fontSize="s"
      display="grid"
      textAlign="center"
      bg="surface.lowestContainer"
      gridTemplateColumns="1fr 1fr 1fr"
    >
      <Box>Price</Box>
      <Box>0.2452</Box>
      <Box>2384</Box>
    </Box>
    {Array.from({ length: 3 }).map(() => (
      <Box
        p="m"
        key={v4()}
        fontSize="s"
        display="grid"
        textAlign="center"
        bg="surface.containerHighest"
        gridTemplateColumns="1fr 1fr 1fr"
      >
        <Box>100</Box>
        <Box>2000</Box>
        <Box>34</Box>
      </Box>
    ))}
  </Box>
);

export default Orderbook;
