module loyalty::loyalty {
  
  use sui::clock::Clock;
  use sui::object::{Self, UID};
  use sui::transfer;
  use sui::coin::{Self, Coin};
  use sui::balance::{Self, Balance};
  use sui::table::{Self, Table};
  use sui::tx_context::{Self, TxContext};

  use deepbook::clob_v2::Pool;
  use deepbook::custodian_v2::AccountCap;
  
  use dex::dex::{Self, DEX, Storage};
  use dex::eth::ETH;
  use dex::usdc::USDC;

  const EMustHavePoints: u64 = 0;
  const ENeeds5Points: u64 = 1;
  
  struct LoyaltyProgram has key {
    id: UID,
    stakes: Table<address, Balance<DEX>>,
    points: Table<address, u64>
  }

  struct NFT has key, store {
    id: UID
  }

  fun init(ctx: &mut TxContext) {
    // We initiate the LoyalProgram and its fields and share with the network
    transfer::share_object(LoyaltyProgram { id: object::new(ctx), stakes: table::new(ctx), points: table::new(ctx) });
  }

  public fun get_user_data(program: &LoyaltyProgram, user: address): (u64, u64) {
    // We check if the he is registered
    let user_has_points = table::contains(&program.points, user);
    let user_has_stake = table::contains(&program.stakes, user);

    // if the user is registered, we read the values, if not we return 0
    (
      if (user_has_stake) balance::value(table::borrow(&program.stakes, user)) else 0,
      if (user_has_points) *table::borrow(&program.points, user) else 0
    )
  }

  public fun get_reward(program: &mut LoyaltyProgram, ctx: &mut TxContext): NFT {
    // Save sender in memory
    let user = tx_context::sender(ctx);

    // If the user has no points, he cannot proceed
    assert!(table::contains(&program.points, user), EMustHavePoints);

    // Get a mut reference to the user points
    let points = table::borrow_mut(&mut program.points, user);

    // Make sure he has at least 5 points
    assert!(*points >= 5, ENeeds5Points);

    // Deduct 5 points
    *points = *points - 5;

    // Mint the reward
    NFT {
      id: object::new(ctx)
    }
  }

  public fun stake(
    program: &mut LoyaltyProgram,
    stake: Coin<DEX>,
    ctx: &mut TxContext
  ) {
    
    // Save the caller in memory
    let sender = tx_context::sender(ctx);

    // If he never deposited we register him
    if (table::contains(&program.stakes, sender)) {
      table::add(&mut program.stakes, sender, balance::zero());
    };

    // Deposit the coin in the contract
    balance::join(table::borrow_mut(&mut program.stakes, sender), coin::into_balance(stake));
  }

  public fun unstake(
    program: &mut LoyaltyProgram,
    ctx: &mut TxContext
  ): Coin<DEX> {
    // Get a mut reference of the user balance
    let stake_balance = table::borrow_mut(&mut program.stakes, tx_context::sender(ctx));

    // Save the total balance amount in memory
    let value = balance::value(stake_balance);

    // unstake the balance into a coin
    coin::take(stake_balance, value, ctx)
  }

  public fun entry_place_market_order(
    program: &mut LoyaltyProgram,
    self: &mut Storage,
    pool: &mut Pool<ETH, USDC>,
    account_cap: &AccountCap,
    quantity: u64,
    is_bid: bool,
    base_coin: Coin<ETH>,
    quote_coin: Coin<USDC>,
    c: &Clock,
    ctx: &mut TxContext,   
  ) {
    // Call place market order
    let (eth, usdc, coin_dex) = place_market_order(program, self, pool, account_cap, quantity, is_bid, base_coin, quote_coin, c, ctx);
    // Save sender in memory
    let sender = tx_context::sender(ctx);

    // transfer coin if it has value or destroy it
    transfer_coin(eth, sender);
    transfer_coin(usdc, sender);
    transfer_coin(coin_dex, sender);
  }

  // @ User can swap via the program to earn points
  public fun place_market_order(
    program: &mut LoyaltyProgram,
    self: &mut Storage,
    pool: &mut Pool<ETH, USDC>,
    account_cap: &AccountCap,
    quantity: u64,
    is_bid: bool,
    base_coin: Coin<ETH>,
    quote_coin: Coin<USDC>,
    c: &Clock,
    ctx: &mut TxContext,    
  ): (Coin<ETH>, Coin<USDC>, Coin<DEX>) {
    let (eth, usdc, coin_dex) = dex::place_market_order(self, pool, account_cap, quantity, is_bid, base_coin, quote_coin, c, ctx);

    increment_points(program, tx_context::sender(ctx));

    (eth, usdc, coin_dex)
  }

  fun increment_points(program: &mut LoyaltyProgram, user: address) {
    // If the user never staked he does not earn any points
    if (table::contains(&program.stakes, user)) {
      let stake_amount = table::borrow(&program.stakes, user);

      // If the user has 0 DEX tokens staked he earns no points
      if (balance::value(stake_amount) != 0) {
        
        // If the user is registered increment his points, if not register him
        if (table::contains(&program.points, user)) {
          // Borrow mut
          let points = table::borrow_mut(&mut program.points, user);
          // Increment
          *points = *points + 1;
        } else {
          table::add(&mut program.points, user, 1)
        };
      };
    };
  }

  fun transfer_coin<CoinType>(c: Coin<CoinType>, sender: address) {
    // check if the coin has any value
    if (coin::value(&c) == 0) {
      // destroy if it does not
      coin::destroy_zero(c);
    } else {
    // If it has value we transfer
    transfer::public_transfer(c, sender);
    }; 
  }
}