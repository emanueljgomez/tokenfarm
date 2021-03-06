const { assert } = require("chai");

const DaiToken = artifacts.require("DaiToken");
const DappToken = artifacts.require("DappToken");
const TokenFarm = artifacts.require("TokenFarm");

// Chai is a library for testing
require("chai")
  .use(require("chai-as-promised"))
  .should();

// This function converts Ether value to Wei value to avoid
// writing the same longer code over and over again
function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

contract("TokenFarm", ([owner, investor]) => {
  let daiToken, dappToken, tokenFarm;
  // This function will run before all tests are run,
  // the migration process is recreated here for testing purposes
  before(async () => {
    // Load contracts
    daiToken = await DaiToken.new();
    dappToken = await DappToken.new();
    tokenFarm = await TokenFarm.new(dappToken.address, daiToken.address);

    // Transfer all Dapp tokens to farm (1 million)
    await dappToken.transfer(tokenFarm.address, tokens("1000000"));

    // Send initial amount of fake DAI to investor
    await daiToken.transfer(investor, tokens("100"), { from: owner });
  });

  // ====== TESTS START HERE ======
  // Test Suite 1 -- Fake DAI
  describe("Mock DAI deployment", async () => {
    it("Contract has a name", async () => {
      const name = await daiToken.name();
      assert.equal(name, "Mock DAI Token");
    });
  });

  // Test Suite 2 -- Dapp Token
  describe("Dapp Token deployment", async () => {
    it("Contract has a name", async () => {
      const name = await dappToken.name();
      assert.equal(name, "DApp Token");
    });
  });

  // Test Suite 3 -- Token Farm
  describe("Token Farm deployment", async () => {
    it("Contract has a name", async () => {
      const name = await tokenFarm.name();
      assert.equal(name, "Dapp Token Farm");
    });

    it("Contract has tokens", async () => {
      let balance = await dappToken.balanceOf(tokenFarm.address);
      assert.equal(balance.toString(), tokens("1000000"));
    });
  });

  // Test Suite 4 -- Token Farming
  describe("Farming tokens", async () => {
    it("Rewards investors for staking mDai tokens", async () => {
      let result;

      // Check investor balance before staking
      result = await daiToken.balanceOf(investor);

      assert.equal(
        result.toString(),
        tokens("100"),
        "Investor Mock DAI wallet balance is correct before staking"
      );

      // Stake Mock DAI Tokens
      // Token transactions must be approved first
      await daiToken.approve(tokenFarm.address, tokens("100"), {
        from: investor,
      });
      await tokenFarm.stakeTokens(tokens("100"), { from: investor });

      // Check staking result
      result = await daiToken.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens("0"),
        "Investor Mock DAI wallet balance is correct after staking"
      );

      result = await daiToken.balanceOf(tokenFarm.address);
      assert.equal(
        result.toString(),
        tokens("100"),
        "Token Farm Mock DAI wallet balance is correct after staking"
      );

      result = await tokenFarm.stakingBalance(investor);
      assert.equal(
        result.toString(),
        tokens("100"),
        "Investor staking balance is correct after staking"
      );

      result = await tokenFarm.isStaking(investor);
      assert.equal(
        result.toString(),
        "true",
        "Investor staking status is correct after staking"
      );

      // Issue Token
      await tokenFarm.issueTokens({ from: owner });

      // Check balances after issuance
      result = await dappToken.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens("100"),
        "Investor DApp Tokens wallet balance is correct after issuance"
      );

      // Ensure that only owner can issue tokens
      await tokenFarm.issueTokens({ from: investor }).should.be.rejected;

      // Unstake tokens
      await tokenFarm.unstakeTokens({ from: investor });

      // Check results after unstaking
      result = await daiToken.balanceOf(investor);
      assert.equal(
        result.toString(),
        tokens("100"),
        "Investor Mock DAI wallet balance is correct after unstaking"
      );

      result = await daiToken.balanceOf(tokenFarm.address);
      assert.equal(
        result.toString(),
        tokens("0"),
        "Token Farm Mock DAI balance is correct after unstaking"
      );

      result = await tokenFarm.stakingBalance(investor);
      assert.equal(
        result.toString(),
        tokens("0"),
        "Investor staking balance is correct after unstaking"
      );

      result = await tokenFarm.isStaking(investor);
      assert.equal(
        result.toString(),
        "false",
        "Investor staking status is orrect after unstaking"
      );
    });
  });
});
