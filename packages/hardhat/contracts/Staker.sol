// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  event Stake(address,uint256);

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;

  uint256 public timne  = 72 hours;
  uint256 public deadline = block.timestamp + timne;

  bool public openForWithdraw = false;

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
      bool completed = exampleExternalContract.completed();
      require(!completed);
      _;
  }

  function  stake () public payable {
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  function execute() public notCompleted {

    if(deadline <= block.timestamp && threshold <= balances[msg.sender]) {
      exampleExternalContract.complete{value: address(this).balance}();
      resetDeadline();
      //return;
    }

    if(deadline <= block.timestamp && threshold > balances[msg.sender]) {
      openForWithdraw = true;
      resetDeadline();
      //return;
    }
  }

  function timeLeft() public view returns (uint256){


    uint256 timestamp = block.timestamp;

    if(deadline > timestamp) {
      return deadline - timestamp;
    }
    else
    {
        return 0 ;
    }
  }

  function withdraw() public notCompleted payable{
    if(openForWithdraw) {
      address payable payment = payable(msg.sender);
      payment.transfer(balances[msg.sender]);
    }
  }


  function resetDeadline() private {
    deadline = block.timestamp + timne;
  }

  receive() external payable {
    stake();
  }


  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
