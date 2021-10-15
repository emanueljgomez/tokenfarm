pragma solidity ^0.5.0;

// Tokens are imported so the contract is aware of them
import "./DappToken.sol";
import "./DaiToken.sol";

// 'Token Farm' is a simple staking dapp where
// the user deposits 'Dai' tokens and receives 'Dapp' tokens
contract TokenFarm {
    // State variable, this is going to be stored in the blockchain
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;

    // Constructor function will run only once
    // whenever the smart contract is deployed to the network
    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        // Local variables are asigned to state variables so
        // they could be accessed by other functions
        dappToken = _dappToken;
        daiToken = _daiToken;
    }
}
