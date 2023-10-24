module dex::test_dex {
  use sui::math;
  use sui::sui::SUI;
  use sui::clock::{Self, Clock};
  use sui::tx_context::TxContext;
  use sui::test_utils::assert_eq;
  use sui::coin::{Self, mint_for_testing, burn_for_testing as burn, Coin, TreasuryCap};
  use sui::test_scenario::{Self as test, Scenario,  next_tx, ctx};

  use deepbook::clob_v2::{Self as clob, Pool};
  use deepbook::custodian_v2::AccountCap;

  use dex::dex::{Self, Storage, AdminCap};
  use dex::eth::{Self, ETH};
  use dex::usdc::{Self, USDC};

  fun set_up_test(test: &mut Scenario, c: &Clock) {
    let (alice, bob) = people();

    // Set up tests
    next_tx(test, alice);
    {
      eth::init_for_testing(ctx(test));
      usdc::init_for_testing(ctx(test));
      dex::init_for_testing(ctx(test));
    };

    // Create pool
    next_tx(test, alice);
    {
      dex::create_pool(mint<SUI>(100, 9, ctx(test)),ctx(test));
    };

    // Create DEX state
    // Deposit coins in the pool and add caps
    next_tx(test, alice);
    {
      let storage = test::take_shared<Storage>(test);
      let eth_cap = test::take_from_sender<TreasuryCap<ETH>>(test);
      let usdc_cap = test::take_from_sender<TreasuryCap<USDC>>(test);

      dex::create_state(
        &mut storage,
        eth_cap,
        usdc_cap,
        ctx(test)
      );
      test::return_shared(storage);
    };

    // Create an account cap for Bob
    next_tx(test, alice);
    {
      clob::mint_account_cap_transfer(bob, ctx(test));
    };


    // Fill the pool
    next_tx(test, alice);
    {
      let storage = test::take_shared<Storage>(test);
      let admin_cap = test::take_from_sender<AdminCap>(test);
      let pool = test::take_shared<Pool<ETH, USDC>>(test);
      let account_cap = test::take_from_sender<AccountCap>(test);

      dex::fill_pool(&admin_cap, &mut storage, &mut pool, c, &account_cap, ctx(test));

      test::return_shared(storage);
      test::return_shared(pool);
      test::return_to_sender(test, account_cap);
      test::return_to_sender(test, admin_cap);
    };
  }
  
  #[test]
  fun test_market_orders() {
    let scenario = scenario();

    let test = &mut scenario;
    
    let (_, bob) = people();
    let c = clock::create_for_testing(ctx(test));

    set_up_test(test, &c);

    // Create an account cap for Bob
    next_tx(test, bob);
    {
      let account_cap = test::take_from_sender<AccountCap>(test);
      let pool = test::take_shared<Pool<ETH, USDC>>(test);
      
      let (eth_coin, usdc_coin) = clob::place_market_order<ETH, USDC>(
        &mut pool, 
        &account_cap, 
        1, 
        add_decimals(1, 9),
        true,
        coin::zero<ETH>(ctx(test)),
        mint<USDC>(130, 9, ctx(test)),
        &c,
        ctx(test)
      );

    assert_eq(burn(eth_coin), 1000000000); // 1ETH
    assert_eq(burn(usdc_coin), 9700000000); // Got back 9.7 USDC

    test::return_shared(pool);
    test::return_to_sender(test, account_cap);
  };

    clock::destroy_for_testing(c);
    test::end(scenario);   
  }

  // Utils

  public fun scenario(): Scenario { test::begin(@0x1) }

  public fun people():(address, address) { (@0xBEEF, @0x1337)}

  public fun mint<T>(amount: u64, decimals: u8, ctx: &mut TxContext): Coin<T> {
    mint_for_testing<T>(amount * math::pow(10, decimals), ctx)
  }

  public fun add_decimals(x: u64, decimals: u8): u64 {
    x * math::pow(10, decimals)
  }  
}