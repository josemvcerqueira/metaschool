#[test_only]
module loyalty::loyalty_test {

  use sui::clock;
  use sui::transfer;
  use sui::test_utils::assert_eq;
  use sui::coin::{Self, mint_for_testing, burn_for_testing};
  use sui::test_scenario::{Self as test, Scenario,  next_tx, ctx};

  use deepbook::custodian_v2::AccountCap;
  use deepbook::clob_v2:: {Self as clob, Pool};

  use dex::eth::ETH;
  use dex::test_dex;
  use dex::usdc::USDC;
  use dex::dex::Storage;

  use loyalty::loyalty::{Self, LoyaltyAccount};

  const FLOAT_SCALING: u64 = 1_000_000_000; // 1e9

  fun set_up_test(test: &mut Scenario) {
    let (alice, _) = people();
    let c = clock::create_for_testing(ctx(test));

    test_dex::set_up_test(test, &c);

    next_tx(test, alice);
    {
      let account = loyalty::create_account(ctx(test));
      transfer::public_transfer(account, alice);
    };
    clock::destroy_for_testing(c);
  }

#[test]
 fun test_create_account() {
    let scenario = scenario();

    let test = &mut scenario;
    
    let (alice, _) = people();

    set_up_test(test);

    // Create an account cap for Bob
    next_tx(test, alice); 
    {
      let account = loyalty::create_account(ctx(test));

      assert_eq(loyalty::loyalty_account_stake(&account), 0);
      assert_eq(loyalty::loyalty_account_points(&account), 0);

      loyalty::destroy_account_for_testing(account);
    };
    
    test::end(scenario);  
 }

 #[test]
 fun test_stake() {
    let scenario = scenario();

    let test = &mut scenario;
    
    let (alice, _) = people();

    set_up_test(test);

    // Create an account cap for Bob
    next_tx(test, alice); 
    {
      let account = test::take_from_sender<LoyaltyAccount>(test);

      loyalty::stake(&mut account, mint_for_testing(1000, ctx(test)));

      assert_eq(loyalty::loyalty_account_stake(&account), 1000);
      assert_eq(loyalty::loyalty_account_points(&account), 0);

      test::return_to_sender(test, account);      
    };
    test::end(scenario);  
 }

  #[test]
 fun test_unstake() {
    let scenario = scenario();

    let test = &mut scenario;
    
    let (alice, _) = people();

    set_up_test(test);

    // Create an account cap for Bob
    next_tx(test, alice); 
    {
      let account = test::take_from_sender<LoyaltyAccount>(test);

      loyalty::stake(&mut account, mint_for_testing(1000, ctx(test)));

      assert_eq(loyalty::loyalty_account_stake(&account), 1000);
      assert_eq(loyalty::loyalty_account_points(&account), 0);

      let coin_unstaked = loyalty::unstake(&mut account, ctx(test));

      assert_eq(burn_for_testing(coin_unstaked), 1000);

      assert_eq(loyalty::loyalty_account_stake(&account), 0);
      assert_eq(loyalty::loyalty_account_points(&account), 0);

      test::return_to_sender(test, account);      
    };
    test::end(scenario);  
 }

#[test]
 fun test_place_market_order() {
    let scenario = scenario();

    let test = &mut scenario;
    
    let (alice, _) = people();

    set_up_test(test);
    let c = clock::create_for_testing(ctx(test));

    next_tx(test, alice);
    {
      clob::mint_account_cap_transfer(alice, ctx(test));
    };

    // Create an account cap for Bob
    next_tx(test, alice); 
    {
      let account = test::take_from_sender<LoyaltyAccount>(test);

      let storage = test::take_shared<Storage>(test);
      let account_cap = test::take_from_sender<AccountCap>(test);
      let pool = test::take_shared<Pool<ETH, USDC>>(test);

      loyalty::stake(&mut account, mint_for_testing(1000, ctx(test)));

      assert_eq(loyalty::loyalty_account_points(&account), 0);
      
      let (eth_coin, usdc_coin, coin_dex) = loyalty::place_market_order(
        &mut account,
        &mut storage,
        &mut pool, 
        &account_cap, 
        FLOAT_SCALING,
        true,
        coin::zero<ETH>(ctx(test)),
        mint_for_testing<USDC>(130 * FLOAT_SCALING, ctx(test)),
        &c,
        ctx(test)
      );

      burn_for_testing(eth_coin);
      burn_for_testing(usdc_coin);
      burn_for_testing(coin_dex);

      assert_eq(loyalty::loyalty_account_points(&account), 1);

      let (eth_coin, usdc_coin, coin_dex) = loyalty::place_market_order(
        &mut account,
        &mut storage,
        &mut pool, 
        &account_cap, 
        FLOAT_SCALING,
        true,
        coin::zero<ETH>(ctx(test)),
        mint_for_testing<USDC>(130 * FLOAT_SCALING, ctx(test)),
        &c,
        ctx(test)
      );

      burn_for_testing(eth_coin);
      burn_for_testing(usdc_coin);
      burn_for_testing(coin_dex);

      assert_eq(loyalty::loyalty_account_points(&account), 2);

      let (eth_coin, usdc_coin, coin_dex) = loyalty::place_market_order(
        &mut account,
        &mut storage,
        &mut pool, 
        &account_cap, 
        FLOAT_SCALING,
        true,
        coin::zero<ETH>(ctx(test)),
        mint_for_testing<USDC>(130 * FLOAT_SCALING, ctx(test)),
        &c,
        ctx(test)
      );

      burn_for_testing(eth_coin);
      burn_for_testing(usdc_coin);
      burn_for_testing(coin_dex);

      assert_eq(loyalty::loyalty_account_points(&account), 3);

      let (eth_coin, usdc_coin, coin_dex) = loyalty::place_market_order(
        &mut account,
        &mut storage,
        &mut pool, 
        &account_cap, 
        FLOAT_SCALING,
        true,
        coin::zero<ETH>(ctx(test)),
        mint_for_testing<USDC>(130 * FLOAT_SCALING, ctx(test)),
        &c,
        ctx(test)
      );

      burn_for_testing(eth_coin);
      burn_for_testing(usdc_coin);
      burn_for_testing(coin_dex);

      assert_eq(loyalty::loyalty_account_points(&account), 4);

      let (eth_coin, usdc_coin, coin_dex) = loyalty::place_market_order(
        &mut account,
        &mut storage,
        &mut pool, 
        &account_cap, 
        FLOAT_SCALING,
        true,
        coin::zero<ETH>(ctx(test)),
        mint_for_testing<USDC>(130 * FLOAT_SCALING, ctx(test)),
        &c,
        ctx(test)
      );

      assert_eq(loyalty::loyalty_account_points(&account), 5);

      burn_for_testing(eth_coin);
      burn_for_testing(usdc_coin);
      burn_for_testing(coin_dex);

      let nft = loyalty::get_reward(&mut account, ctx(test));

      assert_eq(loyalty::loyalty_account_points(&account), 0);

      loyalty::destroy_nft_for_testing(nft);

      test::return_to_sender(test, account);    
      test::return_shared(pool);
      test::return_shared(storage);
      test::return_to_sender(test, account_cap);  
    };
    clock::destroy_for_testing(c);
    test::end(scenario);  
 }

 #[test]
 #[expected_failure(abort_code = loyalty::loyalty::ENeeds5Points)]
 fun test_get_reward_error_not_enough_points() {
    let scenario = scenario();

    let test = &mut scenario;
    
    let (alice, _) = people();

    set_up_test(test);

    // Create an account cap for Bob
    next_tx(test, alice); 
    {
      let account = test::take_from_sender<LoyaltyAccount>(test);

      let nft = loyalty::get_reward(&mut account, ctx(test));

      loyalty::destroy_nft_for_testing(nft);

      test::return_to_sender(test, account);
    };
    test::end(scenario);  
 }

  // Utils

  public fun scenario(): Scenario { test::begin(@0x1) }

  public fun people():(address, address) { (@0xBEEF, @0x1337)}

}