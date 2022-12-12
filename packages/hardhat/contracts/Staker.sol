// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint public immutable threshold = 1 ether;
  uint public deadline;
  bool public openForWithdraw = false;


  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      deadline = block.timestamp + 72 hours;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  event Stake(address addr, uint amount);

  modifier notCompleted() {
    require(!exampleExternalContract.completed(), "Contract can only execute once yaheard");
    require(!openForWithdraw, "Didn't reach threshold, wiithdraw your funds");
    _;
  }

  function stake() public payable  {
   require(block.timestamp < deadline, "Too late bub");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  function execute() public notCompleted {
    require(block.timestamp >= deadline, "it's too early, chill");

    if(address(this).balance >= threshold) {
      exampleExternalContract.complete
      {value: address(this).balance}();
    } else {
       openForWithdraw = true;
       console.log(openForWithdraw);
    }

  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public  {
    require(openForWithdraw, "Contract not elligible for withdrawals rn if deadline has passed, please execute first");
    require(balances[msg.sender] > 0, "You've got nothing to withdraw homie");
    payable(msg.sender).transfer(balances[msg.sender]);
    balances[msg.sender] = 0;
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return(deadline-block.timestamp);
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

}
