module loyalty::loyalty {
  
  use sui::clock::Clock;
  use sui::object::{Self, UID};
  use sui::coin::{Self, Coin};
  use sui::tx_context::TxContext;
  use sui::balance::{Self, Balance};

  use deepbook::clob_v2::Pool;
  use deepbook::custodian_v2::AccountCap;
  
  use dex::eth::ETH;
  use dex::usdc::USDC;
  use dex::dex::{Self, DEX, Storage};

  const ENeeds5Points: u64 = 0;

  struct LoyaltyAccount has key, store {
    id: UID,
    // Amount of DEX Coin staked in the program
    stake: Balance<DEX>,
    // Amount of points accumulated per swap
    points: u64
  }
  
  struct NFT has key, store {
    id: UID
  }

  // @dev It creates an account object to keep track of a user points and stake amount
  public fun create_account(ctx: &mut TxContext): LoyaltyAccount {
    LoyaltyAccount {
      id: object::new(ctx),
      stake: balance::zero(),
      points: 0
    }
  }

  // @dev It allows a module to read the amount of DEX coins staked in an `LoyaltyAccount`
  public fun loyalty_account_stake(account: &LoyaltyAccount): u64 {
    balance::value(&account.stake)
  }

  // @dev It allows a module to read the number of points in a `LoyaltyAccount`
  public fun loyalty_account_points(account: &LoyaltyAccount): u64 {
    account.points
  }

  // @dev It mints an NFT to the user in exchange for 5 points
  public fun get_reward(account: &mut LoyaltyAccount, ctx: &mut TxContext): NFT {
    // Make sure he has at least 5 points
    assert!(account.points >= 5, ENeeds5Points);

    // Deduct 5 points
    let points_ref = &mut account.points;
    *points_ref = *points_ref - 5;

    // Mint the reward
    NFT {
      id: object::new(ctx)
    }
  }

  public fun stake(
    account: &mut LoyaltyAccount,
    stake: Coin<DEX>
  ) {
    // Deposit the coin in the contract
    balance::join(&mut account.stake, coin::into_balance(stake));
  }

  public fun unstake(
    account: &mut LoyaltyAccount,
    ctx: &mut TxContext
  ): Coin<DEX> {
    // Save the total balance amount in memory
    let value = loyalty_account_stake(account);

    // unstake the balance into a coin
    coin::take(&mut account.stake, value, ctx)
  }

  // @ User can swap via the program to earn points
  public fun place_market_order(
    account: &mut LoyaltyAccount,
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

          // If the user has 0 DEX tokens staked he earns no points
      if (loyalty_account_stake(account) != 0) {
        
          // Borrow mut
          let points_ref = &mut account.points;
          // Increment
          *points_ref = *points_ref + 1;
      };

    (eth, usdc, coin_dex)
  }

  // @dev It allows a test file to destroy the Loyalty Account object
  #[test_only]
  public fun destroy_account_for_testing(account: LoyaltyAccount) {
    // @dev Properties without the drop ability must be destroyed via their libraries
    let LoyaltyAccount { id, stake, points: _ } = account;
    balance::destroy_for_testing(stake);
    object::delete(id);
  }

  // @dev It allows a test file to destroy the NFT object
  #[test_only]
  public fun destroy_nft_for_testing(nft: NFT) {
    let NFT { id} = nft;
    object::delete(id);
  }
}