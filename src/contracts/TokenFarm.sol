pragma solidity ^0.5.0;

// Tokens are imported so the contract is aware of them
import "./DappToken.sol";
import "./DaiToken.sol";

// 'Token Farm' is a simple staking dapp where
// the user deposits 'Dai' tokens (fake) and receives 'Dapp' tokens
contract TokenFarm {
    // State variable, this is going to be stored in the blockchain
    string public name = "Dapp Token Farm";
    address public owner; // declares 'owner' variable, type 'address'. Will be used in future requirements
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
        // Local variables (types are tokens) are assigned to state variables so
        // they can be accessed by other functions
        dappToken = _dappToken;
        daiToken = _daiToken;
        // The first msg.sender (deployer account) is assigned to 'owner' state variable
        owner = msg.sender;
    }

    /* ================================================== */

    // 1 - Token staking logic (Deposit)
    function stakeTokens(uint256 _amount) public {
        // === TRANSFER DAI TOKENS TO THIS CONTRACT FOR STAKING ===
        // Require amount greater than 0
        require(_amount > 0, "Amount cannot be 0");
        // require: if the condition is not met (result equals 'false') then the function won't be executed

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

    /* ================================================== */

    // 2 - Token Unstaking (Withdraw)
    function unstakeTokens() public {
        // Fetch staking balance
        uint256 balance = stakingBalance[msg.sender];
        // Require balance amount to be greater than 0
        require(balance > 0, "Staking balance cannot be 0");
        // Transfer Mock DAI tokens to this contract for staking
        daiToken.transfer(msg.sender, balance);
        // Reset staking balance
        stakingBalance[msg.sender] = 0;
        // Update staking status
        isStaking[msg.sender] = false;
    }

    /* ================================================== */

    // 3 - Issuing tokens
    function issueTokens() public {
        // Require Token Issuer to be the Owner of the contract (only owner can call this function)
        require(msg.sender == owner, "Caller must be the owner");

        for (uint256 i = 0; i < stakers.length; i++) {
            // Get recipient from the array and save in a variable:
            address recipient = stakers[i];
            // Fetch recipient's account balance:
            uint256 balance = stakingBalance[recipient];
            // Transfer Dapp Tokens (same amount as deposited Dai):
            if (balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }
}
