const { assert } = require("chai");
const { default: Web3 } = require("web3");

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
});
