// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;


contract DonationContract {

    error DonationContract__WetinBeThis();

    address private owner;

    uint public immutable i_goal;

    uint256 public totalDonations;

    uint256 public donationsCount;

    struct Donation {
        uint256 value;
        uint256 time;
    }

    constructor(uint256 _i_goal) {
        owner = payable(msg.sender);
        i_goal = _i_goal;
    }


    mapping(address => Donation[]) public addressToAmountFunded;
    
    function donate() public payable {
        if(msg.value <= 0) {
            revert DonationContract__WetinBeThis();
        }
        Donation memory donation = Donation(msg.value, block.timestamp);
        donationsCount++;
        totalDonations = totalDonations + msg.value;
        addressToAmountFunded[msg.sender].push(donation);
        if(totalDonations > i_goal) {
            revert("total donations cant be greater than aimed goal !!. it just can't, im sorry");
        }
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function totalDonationsFromMe() public view returns(uint256){
        return addressToAmountFunded[msg.sender].length;
    }


    function allMyDonations() public view returns(uint256[] memory values,uint256[] memory dates) {
        uint256 count = totalDonationsFromMe();
        values = new uint256[](count);
        dates = new uint256[](count);

        for(uint256 i =0; i < count; i++) {
            Donation memory donation = addressToAmountFunded[msg.sender][i];
            values[i] = donation.value;
            dates[i] = donation.time;
        }

        return(values, dates);
    }

    function withdraw() public returns(bool) {
        require(msg.sender == owner, "see fooling lmaoo, you sef wan cashout");
        uint256 balance = payable(address(this)).balance;

        require(balance > 0, "shishi no dey inside here o, shibo");

        (bool success, ) = payable(msg.sender).call{value:balance}("");

        require(success, "failed to withdraw");
        return success;
    }

    receive() external payable {
        totalDonations = totalDonations + msg.value;
        donationsCount++;
}

}
