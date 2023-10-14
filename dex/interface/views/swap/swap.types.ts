import { DexFunctions, DexMarket } from '@interest-protocol/sui-amm-sdk';
import { PaginatedCoins } from '@mysten/sui.js/src/types/coin';
import {
  FieldErrors,
  UseFormGetValues,
  UseFormReturn,
  UseFormSetValue,
} from 'react-hook-form';
import { KeyedMutator } from 'swr';

import { CoinData } from '@/interface';

export interface SwapToken extends CoinData {
  value: string;
  locked: boolean;
}

export interface SwapForm {
  to: SwapToken;
  from: SwapToken;
  lock: boolean;
  disabled: boolean;
  maxValue: boolean;
}

export interface SwapProps {
  formSwap: UseFormReturn<SwapForm>;
}

export interface SwapBodyProps {
  formSwap: UseFormReturn<SwapForm>;
}

export interface SwapFormProps {
  isLoading: boolean;
  dexMarket: DexMarket;
  formSwap: UseFormReturn<SwapForm>;
  mutate: KeyedMutator<PaginatedCoins['data'] | undefined>;
}

export interface SwapInputProps {
  name: 'to' | 'from';
  formSwap: UseFormReturn<SwapForm>;
}

export interface TextFieldWrapperProps {
  control: UseFormReturn<SwapForm>['control'];
  name: SwapInputProps['name'];
  errors: FieldErrors<SwapForm>;
  currentTokenType: string;
  register: UseFormReturn<SwapForm>['register'];
  currentTokenSymbol: string | null;
  setValue: UseFormSetValue<SwapForm>;
}

export interface SwapSliderProps {
  balance: number;
  setValue: UseFormSetValue<SwapForm>;
  currentValue: number;
}

export interface SwapFieldProps {
  setValue: UseFormSetValue<SwapForm>;
  getValues: UseFormGetValues<SwapForm>;
}

export interface SwapManagerWrapperProps {
  formSwap: SwapProps['formSwap'];
  dexMarket: DexMarket;
}

export interface SwapPathObject {
  baseTokens: ReadonlyArray<string>;
  coinInType: string;
  coinOutType: string;
  functionName: DexFunctions;
  typeArgs: Array<string>;
}

export interface SwapPathProps {
  swapPath: SwapPathObject;
}
