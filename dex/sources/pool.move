module dex::pool {

  use sui::transfer;
  use sui::event::emit;
  use sui::coin::{Self, Coin};
  use sui::object::{Self, UID};
  use sui::balance::{Self, Balance};
  use sui::tx_context::{Self, TxContext};

  use dex::math;
  use dex::eth::{Self, ETH, ETHStorage};
  use dex::usdc::{Self, USDC, USDCStorage};
  use dex::lp_token::{Self, LPTokenStorage};

  const INITIAL_ETH_AMOUNT: u64 = 1_000_000_000_000; // 1000e9 - 1000 ETH
  const INITIAL_USDC_AMOUNT: u64 = 1800000000000; // 1800000e6 - 1800000 USDC

  const EAlreadyStarted: u64 = 0;
  const EPoolNotStarted: u64 = 1;
  const ESlippage: u64 = 2;
  const EWrongK: u64 = 3;

  // Events 

  struct Swap<phantom CoinIn, phantom CoinOut> has copy, drop {
    amount_in: u64,
    amount_out: u64,
    sender: address
  }

  // We will share the pool with the entire Sui network so anyone can interact with it
  // Shared objects only require the key ability
  // Balance is an object that holds the value inside a Coin. It does not have a unique ID, so it is best to be used inside modules
  struct Pool has key {
    id: UID, // unique identifier
    balance_x: Balance<ETH>, // Amount of ETH in the pool
    balance_y: Balance<USDC>, // Amount of USDC in the pool
    started: bool
  }

  fun init(ctx: &mut TxContext) {
    // We create the pool and share with the network
    transfer::share_object(
      Pool {
        id: object::new(ctx),
        balance_x: balance::zero(),
        balance_y: balance::zero(),
        started: false // It indicates if we started the pool
      }
    );
  }

  // We cannot pass the Storage objects in the init function
  // So we need this function to seed the pool
  public fun seed_pool(
    pool: &mut Pool, 
    eth_storage: &mut ETHStorage, 
    usdc_storage: &mut USDCStorage, 
    lp_storage: &mut LPTokenStorage, 
    ctx: &mut TxContext
  ) {
    // We first check if the pool has been started already
    assert!(!pool.started, EAlreadyStarted);
    // We will seed the pool with 1000 ETH and 1800000 USDC
    // The LP Token represents the shares of the liquidity in the pool
    // The seed invvariant is sqrt(1000 * 1800000)
    // To avoid multiplication overflow errors, we cast u64 to u256 
    // Then we square root and cast it back to u64
    // We also burn the initial shares as they do not belong to anyone
    transfer::public_transfer(lp_token::mint(lp_storage, (math::sqrt_u256((INITIAL_ETH_AMOUNT as u256) * (INITIAL_USDC_AMOUNT as u256)) as u64), ctx), @0x0);


    // First we mint 1000 ETH
    // Then we convert into a Balance
    // Then we add to the Pool ETH Balance
    balance::join(&mut pool.balance_x, coin::into_balance(eth::mint(eth_storage, INITIAL_ETH_AMOUNT, ctx)));

    balance::join(&mut pool.balance_y, coin::into_balance(usdc::mint(usdc_storage, INITIAL_USDC_AMOUNT, ctx)));

    // Flag that the pool has been seeded
    pool.started = true;
  }

  // This function allows a user to send ETH to the Pool and get USDC back
  // Always send coins to Functions, do not pass a mut reference
  /*
  * @param pool The pool we are swapping with
  * @param coin_x The Eth we are selling
  * @param min_amount_out The minimum amount of USDC we want to fight slippage
  */
  public fun swap_eth(pool: &mut Pool, coin_x: Coin<ETH>, min_amount_out: u64, ctx: &mut TxContext): Coin<USDC> {
    // make sure that the pool has been seeded before any operation to save gas
    assert!(pool.started, EPoolNotStarted);
    // First save in memory how much ETH is being sent to the pool
    let eth_value = coin::value(&coin_x);

    // Read the amount of ETH and USDC in the pool
    let (eth_balance, usdc_balance) = get_amounts(pool);
    
    // Calculate the invariant before any swaps
    let prev_k = k(eth_balance, usdc_balance);

    // Calculate how much USDC to send to the user
    let usdc_value_out = calculate_value_out(eth_value, eth_balance, usdc_balance);

    assert!(usdc_value_out >= min_amount_out, ESlippage);

    // Emit a Swap Event 
    emit(Swap<ETH, USDC>{ amount_in: eth_value, amount_out: usdc_value_out, sender: tx_context::sender(ctx) });

    // Deposit the ETH in the pool
    balance::join(&mut pool.balance_x, coin::into_balance(coin_x));

    // Take Coin from Pool Balance
    let coin_out = coin::take(&mut pool.balance_y, usdc_value_out, ctx);

    let (eth_balance, usdc_balance) = get_amounts(pool);

    // Insanity Test, we check that the invariant holds after all mutations
    assert!(k(eth_balance, usdc_balance) >= prev_k, EWrongK);

    // Return the coin to the caller
    coin_out
  }

  // This function allows a user to send USDC to the Pool and get ETH back
  /*
  * @param pool The pool we are swapping with
  * @param coin_y The USDC we are selling
  * @param min_amount_out The minimum amount of ETH we want to fight slippage
  */
  public fun swap_usdc(pool: &mut Pool, coin_y: Coin<USDC>, min_amount_out: u64, ctx: &mut TxContext): Coin<ETH> {
    // make sure that the pool has been seeded before any operation to save gas
    assert!(pool.started, EPoolNotStarted);
    // First save in memory how much USDC is being sent to the pool
    let usdc_value = coin::value(&coin_y);

    // Read the amount of ETH and USDC in the pool
    let (eth_balance, usdc_balance) = get_amounts(pool);
    
    // Calculate the invariant before any swaps
    let prev_k = k(eth_balance, usdc_balance);

    // Calculate how much ETH to send to the user
    let eth_value_out = calculate_value_out(usdc_value, usdc_balance, eth_balance);

    // Make sure the user was not frontrun a lot
    assert!(eth_value_out >= min_amount_out, ESlippage);

    // Emit a Swap Event 
    emit(Swap<USDC, ETH>{ amount_in: usdc_value, amount_out: eth_value_out, sender: tx_context::sender(ctx) });

    // Deposit the USDC in the pool
    balance::join(&mut pool.balance_y, coin::into_balance(coin_y));

    // Take Coin from Pool Balance
    let coin_out = coin::take(&mut pool.balance_x, eth_value_out, ctx);

    let (eth_balance, usdc_balance) = get_amounts(pool);

    // Insanity Test, we check that the invariant holds after all mutations
    assert!(k(eth_balance, usdc_balance) >= prev_k, EWrongK);

    // Return the coin to the caller
    coin_out
  }


  // @dev A utility function to read the amount of ETH and USDC in the pool
  // @param pool An immutable reference of the pool
  fun get_amounts(pool: &Pool): (u64, u64) {
    (balance::value(&pool.balance_x), balance::value(&pool.balance_y))
  }
  

  // The pool must keep the same K after swaps
  // K = x * y  - the UniswapV2 invariant
  // @dev We cast u64 to u256 to avoid multiplication overflow errors
  fun k(x: u64, y: u64): u256 {
    (x as u256) * (y as u256)
  }

  // @dev This function calculates how much of the opposite token to send to the user to hold k = x * y
  /*
  * @param coin_in_amount The amount of Coin being sent to the pool
  * @param balance_in The reserves of Coin In in the pool
  * @oaram balance_out The reserves of Coin Out in the pool
  */
  fun calculate_value_out(coin_in_amount: u64, balance_in: u64, balance_out: u64): u64 {

    let (coin_in_amount, balance_in, balance_out) = (
          (coin_in_amount as u256),
          (balance_in as u256),
          (balance_out as u256)
        );

    // @dev read more here https://devweb3.net/an-introduction-to-the-uniswap-v2-math-function/
    // K = x * y
    // k = (x + change in x) * (y - change in y)
    // y -  change in y = k / (x +  change in x)
    // - change in y = k/(x + change in x) - y 
    // change in y = y - k/(x + change in x)
    // We maintain the K invariant = reserveB * amountA / reserveA + amount A
    let numerator = balance_out * coin_in_amount;
    let denominator = balance_in + coin_in_amount; 

    // Divide and convert the value back to u64 and return.
    ((numerator / denominator) as u64) 
  }  

  // Quote Function for the frontemd
  // @dev It tells how much USDC we will get when selling {amount_in} of ETH
  public fun quote_swap_eth(pool: &Pool, amount_in: u64): u64 {
    let (eth_balance, usdc_balance) = get_amounts(pool);
    calculate_value_out(amount_in, eth_balance, usdc_balance)
  }   

  // Quote Function for the frontemd
  // @dev It tells how much ETH we will get when selling {amount_in} of USDC
  public fun quote_swap_usdc(pool: &Pool, amount_in: u64): u64 {
    let (eth_balance, usdc_balance) = get_amounts(pool);
    calculate_value_out(amount_in, usdc_balance, eth_balance)
  } 
}