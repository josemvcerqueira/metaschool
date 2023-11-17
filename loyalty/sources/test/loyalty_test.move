#[test_only]
module loyalty::loyalty_test {

  use sui::clock;
  use sui::transfer;
  use sui::test_utils::assert_eq;
  use sui::coin::{mint_for_testing, burn_for_testing};
  use sui::test_scenario::{Self as test, Scenario,  next_tx, ctx};

  use deepbook::clob_v2:: Pool;
  use deepbook::custodian_v2::AccountCap;

  use dex::test_dex;
  use dex::dex::{Self, Storage};
  use dex::eth::{Self, ETH};
  use dex::usdc::{Self, USDC};

  use loyalty::loyalty::{Self, LoyaltyAccount};

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

    // Create an account cap for Bob
    next_tx(test, alice); 
    {
      let account = test::take_from_sender<LoyaltyAccount>(test);

     

      test::return_to_sender(test, account);      
    };
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