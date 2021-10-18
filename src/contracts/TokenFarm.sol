pragma solidity ^0.5.0;

// Tokens are imported so the contract is aware of them
import "./DappToken.sol";
import "./DaiToken.sol";

// 'Token Farm' is a simple staking dapp where
// the user deposits 'Dai' tokens (fake) and receives 'Dapp' tokens
contract TokenFarm {
    // State variable, this is going to be stored in the blockchain
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;

    // This array will keep track of all the users that have ever staked
    // for future reward issuing
    address[] public stakers;

    // Mapping is a key value store, a data structure
    // Key => Value -- "Give me the Key, so I return the Value"
    // In this case, the Key is the investor's address and the returned
    // value will be the amount of staked tokens of said address
    mapping(address => uint256) public stakingBalance;

    // This hash mapping will return a boolean response,
    // it will be used to check if the user HAS EVER staked
    mapping(address => bool) public hasStaked;

    // This hash mapping will return a boolean response,
    // it will be used to check if the user possesses currently staked tokens
    mapping(address => bool) public isStaking;

    // Constructor function will run only once
    // whenever the smart contract is deployed to the network
    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        // Local variables are asigned to state variables so
        // they could be accessed by other functions
        dappToken = _dappToken;
        daiToken = _daiToken;
    }

    // 1 - Token staking logic (Deposit)
    function stakeTokens(uint256 _amount) public {
        // === TRANSFER DAI TOKENS TO THIS CONTRACT FOR STAKING ===
        daiToken.transferFrom(msg.sender, address(this), _amount);
        // transferFrom: a native function from the Token Contract (parameters: sender, receiver, amount)
        // msg.sender: a special, global, native variable proper of Solidity
        // address(this): it refers to the actual contract, converted to an 'address' format

        // === UPDATE STAKING BALANCE ===
        // Here the stakingBalance mapping is called and executed
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        // === ADD USERS TO 'stakers' ARRAY ===
        // Conditional is used to verify if user has staked already,
        // this is to avoid conflicts in the array, in case a user stakes more than once
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // === UPDATE STAKING STATUS ===
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // 2 - Token Unstaking (Withdraw)

    // 3 - Issuing tokens
}
