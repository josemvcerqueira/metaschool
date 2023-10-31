// This contract will seed the pool and allow users to trade agaisnt it 
// It will also reward users with a token every 2 swaps
module dex::dex {
  use std::option;
  use std::type_name::{get, TypeName};

  use sui::transfer;
  use sui::sui::SUI;
  use sui::clock::{Clock};
  use sui::balance::{Self, Supply};
  use sui::object::{Self, UID};
  use sui::table::{Self, Table};
  use sui::dynamic_field as df;
  use sui::tx_context::{Self, TxContext};
  use sui::coin::{Self, TreasuryCap, Coin};

  use deepbook::clob_v2::{Self as clob, Pool};
  use deepbook::custodian_v2::AccountCap;

  use dex::eth::ETH;
  use dex::usdc::USDC;

  const CLIENT_ID: u64 = 122227;
  const MAX_U64: u64 = 18446744073709551615;
  // Restrictions on limit orders.
  const NO_RESTRICTION: u8 = 0;
  const FLOAT_SCALING: u64 = 1_000_000_000; // 1e9

  const EAlreadyMintedThisEpoch: u64 = 0;

  // One time witness to create the DEX coin
  struct DEX has drop {}

  struct Data<phantom CoinType> has store {
    cap: TreasuryCap<CoinType>,
    /*
    * This table will store user address => last epoch minted
    * this is to make sure that users can only mint tokens once per epoch
    */
    faucet_lock: Table<address, u64>
  }

  // This is an object because it has the key ability and a UID
  struct Storage has key {
    id: UID,
    dex_supply: Supply<DEX>,
    swaps: Table<address, u64>,
    account_cap: AccountCap,
    client_id: u64
  }

  #[allow(unused_function)]
  // This function only runs at deployment
  fun init(witness: DEX, ctx: &mut TxContext) { 

  let (treasury_cap, metadata) = coin::create_currency<DEX>(
            witness, 
            9, 
            b"DEX",
            b"DEX Coin", 
            b"Coin of SUI DEX", 
            option::none(), 
            ctx
        );
    
    // Share the metadata with sui network and make it immutable
    transfer::public_freeze_object(metadata);    


    // We share the Storage object with the Sui Network so everyone can pass to functions as a reference
    // We transform the Treasury Cap into a Supply so this module can mint the DEX token
    transfer::share_object(Storage { 
      id: object::new(ctx), 
      dex_supply: coin::treasury_into_supply(treasury_cap), 
      swaps: table::new(ctx),
      // We will store the deployer account_cap here to be able to refill the pool
      account_cap: clob::create_account(ctx),
      client_id: CLIENT_ID
    });
  }

  // * VIEW FUNCTIONS

  public fun user_last_mint_epoch<CoinType>(self: &Storage, user: address): u64 {
    // Load the Coin Data from storage
    let data = df::borrow<TypeName, Data<CoinType>>(&self.id, get<CoinType>());

    // Check if the user has ever used the faucet
    // If so we retrieve the last epoch saved
    if (table::contains(&data.faucet_lock, user)) return *table::borrow(&data.faucet_lock, user);

    // If he never used the faucet we return 0
    0 
  }

  public fun user_swap_count(self: &Storage, user: address): u64 {
    // Check if the user has ever swapped
    // If he has we return the total swap count
    if (table::contains(&self.swaps, user)) return *table::borrow(&self.swaps, user);

    // If he never swapped we return 0
    0
  }

  // * MUT FUNCTIONS

  public fun entry_place_market_order(
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
    let (eth, usdc, coin_dex) = place_market_order(self, pool, account_cap, quantity, is_bid, base_coin, quote_coin, c, ctx);
    // Save sender in memory
    let sender = tx_context::sender(ctx);

    // transfer coin if it has value or destroy it
    transfer_coin(eth, sender);
    transfer_coin(usdc, sender);
    transfer_coin(coin_dex, sender);
  }

  /*
  * @param self The shared object of this contract
  * @param pool The DeepBook pool we are trading with
  * @param account_cap All users on deep book need an AccountCap to place orders
  * @param quantity The number of Base tokens we wish to buy or sell (In this case ETH)
  * @param is_bid Are we buying or selling ETH
  * @param base_coin ETH
  * @param quote_coin USDC
  * @param c The Clock shared object
  */
  public fun place_market_order(
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
  let sender = tx_context::sender(ctx);  

  let client_order_id = 0;
  let dex_coin = coin::zero(ctx);

  // Check if the sender has ever done a swap
  if (table::contains(&self.swaps, sender)) {
    // If he did a swap before, we get the total swaps and increment by one
    let total_swaps = table::borrow_mut(&mut self.swaps, sender);
    let new_total_swap = *total_swaps + 1;
    *total_swaps = new_total_swap;
    // Update the client order id
    client_order_id = new_total_swap;

    // We mint 1 DEX token every 2 swaps to the user
    if ((new_total_swap % 2) == 0) {
      // Increase supply -> Transform into a coin -> Join the coin with Zero Dex coin to return to the user
      coin::join(&mut dex_coin, coin::from_balance(balance::increase_supply(&mut self.dex_supply, FLOAT_SCALING), ctx));
    };
  } else {
    // If he never did a swap we register his account
    table::add(&mut self.swaps, sender, 1);
  };
  
  // place the order
  let (eth_coin, usdc_coin) = clob::place_market_order<ETH, USDC>(
    pool, 
    account_cap, 
    client_order_id, 
    quantity,
    is_bid,
    base_coin,
    quote_coin,
    c,
    ctx
    );


    // 
    (eth_coin, usdc_coin, dex_coin)
  }
  
  // It costs 100 Sui to create a Pool in Deep Book
  public fun create_pool(fee: Coin<SUI>, ctx: &mut TxContext) {
    // Create ETH USDC pool in DeepBook
    // This pool will be shared with the Sui Network
    // Tick size is 1 USDC - 1e9 
    // No minimum lot size
    clob::create_pool<ETH, USDC>(1 * FLOAT_SCALING, 1, fee, ctx);
  }

  // Only call if there are no orders
  public fun fill_pool(
    self: &mut Storage,
    pool: &mut Pool<ETH, USDC>, // The CLOB pool
    c: &Clock, // CLock shares object to know the timestamp on chain
    ctx: &mut TxContext
  ) {
    /*
    * Deposit funds in DeepBook
    * Place Limit Sell Orders
    * Place Buy Sell Orders
    * To allow others users to buy/sell tokens
    */
    create_ask_orders(self, pool, c, ctx);
    create_bid_orders(self, pool, c, ctx);
  }


  // Since the Caps are only created at deployment, this function can only be called once
  public fun create_state(
    self: &mut Storage, 
    eth_cap: TreasuryCap<ETH>, 
    usdc_cap: TreasuryCap<USDC>, 
    ctx: &mut TxContext
  ) {

    // We save the caps inside the Storage object with dynamic object fields
    // The get is a {TypeName} which is unique
    df::add(&mut self.id, get<ETH>(), Data { cap: eth_cap, faucet_lock: table::new(ctx) });
    df::add(&mut self.id, get<USDC>(), Data { cap: usdc_cap, faucet_lock: table::new(ctx) });
  }

  //@dev oNly call this function with ETH and USDC types
  // It mints 100 USDC every epoch or it mints 1 ETH every epoch
  public fun mint_coin<CoinType>(self: &mut Storage, ctx: &mut TxContext): Coin<CoinType> {
    let sender = tx_context::sender(ctx);
    let current_epoch = tx_context::epoch(ctx);
    let type = get<CoinType>();
    // Load the Data struct associated with CoinType
    let data = df::borrow_mut<TypeName, Data<CoinType>>(&mut self.id, type);

    // If the sender has a record in the table, he minted before
    // So we need to check if he is eligible to mint this epoch
    if (table::contains(&data.faucet_lock, sender)){
      // Get his last minted epoch
      let last_mint_epoch = table::borrow(&data.faucet_lock, tx_context::sender(ctx));
      // Check if the current epoch is bigger than the last epoch he minted
      // We deference the last_mint_epoch to remove the pointer
      assert!(current_epoch > *last_mint_epoch, EAlreadyMintedThisEpoch);
    } else {
      // If it is the first mint, we add the default data epoch 0
      table::add(&mut data.faucet_lock, sender, 0);
    };

    // We borrow a mutable reference of the cap
    let last_mint_epoch = table::borrow_mut(&mut data.faucet_lock, sender);
    *last_mint_epoch = tx_context::epoch(ctx);
    // Mint coin 500 USDC or 3 ETH
    coin::mint(&mut data.cap, if (type == get<USDC>()) 100 * FLOAT_SCALING else 1 * FLOAT_SCALING, ctx)
  }

  fun create_ask_orders(
    self: &mut Storage,
    pool: &mut Pool<ETH, USDC>, // The CLOB pool
    c: &Clock, // CLock shares object to know the timestamp on chain
    ctx: &mut TxContext
  ) {

    // Get eth data from storage using dynamic field
    let eth_data = df::borrow_mut<TypeName, Data<ETH>>(&mut self.id, get<ETH>());

    // Deposit 60_000 ETH on the pool
    clob::deposit_base<ETH, USDC>(pool, coin::mint(&mut eth_data.cap, 60000000000000, ctx), &self.account_cap);
    // Limit SELL Order
    // Wanna sell ETH 6000 ETH at 120 USDC
    clob::place_limit_order(
      pool,
      self.client_id,  // ID for this order
     120 * FLOAT_SCALING, 
     60000000000000,
      NO_RESTRICTION,
      false,
      MAX_U64, // no expire timestamp,
      NO_RESTRICTION,
      c,
      &self.account_cap,
      ctx
    );

    self.client_id = self.client_id + 1;
  }

  fun create_bid_orders(
    self: &mut Storage,
    pool: &mut Pool<ETH, USDC>, // The CLOB pool
    c: &Clock, // CLock shares object to know the timestamp on chain
    ctx: &mut TxContext
  ) {
    // Get the USDC data from the storage
    let usdc_data = df::borrow_mut<TypeName, Data<USDC>>(&mut self.id, get<USDC>());

    // Deposit 6_000_000 USDC in the pool
    clob::deposit_quote<ETH, USDC>(pool, coin::mint(&mut usdc_data.cap, 6000000000000000, ctx), &self.account_cap);


        // Limit BUY Order
    // Wanna buy 6000 ETH at 100 USDC or higher
    clob::place_limit_order(
      pool,
      self.client_id, 
      100 * FLOAT_SCALING, 
      60000000000000,
      NO_RESTRICTION,
      true,
      MAX_U64, // no expire timestamp,
      NO_RESTRICTION,
      c,
      &self.account_cap,
      ctx
    );
    self.client_id = self.client_id + 1;
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

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init( DEX {}, ctx);
  }
}