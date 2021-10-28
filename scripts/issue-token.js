const TokenFarm = artifacts.require("TokenFarm");

// Upon execution, this script will call the 'issueTokens'
// function inside TokenFarm.sol
// To run this script on console use this command:
// truffle exec scripts/issue-token.js
module.exports = async function(callback) {
  let tokenFarm = await TokenFarm.deployed();
  await tokenFarm.issueTokens();
  console.log("Tokens issued!");
  callback();
};
