// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
error NotOwner();
contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public immutable i_owner;
    uint256 public constant MINIMUMUSD = 5 * 10 ** 18;
    

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUMUSD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "sender is not the owner");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callsuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callsuccess, "call failed");
    }
    //when someone does not call fund function and sends eth directly to contract address, then we can use receive and fallback functions to handle such cases.

receive() external payable {
    fund();
}
 fallback() external payable {
    fund();
 }
}