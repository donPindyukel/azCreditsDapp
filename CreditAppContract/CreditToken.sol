pragma solidity ^0.4.13;

import './MintableToken.sol';

contract CreditToken is MintableToken {
    struct Bid {
        address borrower;
        address creditor;
        address guarantor;
        uint ammount;
        bool accept;
        bool issued;
    }

    mapping (address => Bid) public currentBid;

    //Bid[] public bids;
   // Bid[] public credits;

    function pushBidOnCredit(uint ammount) public {
        currentBid[msg.sender].borrower = msg.sender;
        currentBid[msg.sender].ammount = ammount;
        currentBid[msg.sender].creditor = 0x0;
        currentBid[msg.sender].guarantor = 0x0;
        currentBid[msg.sender].accept = false;
        currentBid[msg.sender].issued = false;
    }

    function acceptOnCredit(address borrower) public {
        currentBid[borrower].guarantor = msg.sender;
        require(currentBid[borrower].borrower == borrower);
        if (currentBid[borrower].creditor != 0x0) {
            currentBid[borrower].accept = true;
        }
    }

    function creditorOnCredit(address borrower) public {
        currentBid[borrower].creditor = msg.sender;
        require(currentBid[borrower].borrower == borrower);
        if (currentBid[borrower].guarantor != 0x0) {
            currentBid[borrower].accept = true;
            approve(currentBid[borrower].borrower, currentBid[borrower].ammount);
        }
    }

    function checkBidStatus(address borrower) public {
        require(currentBid[borrower].borrower == borrower);
        if (currentBid[borrower].accept) {
            assert(balances[currentBid[borrower].guarantor] >= currentBid[borrower].ammount);
            assert(balances[currentBid[borrower].creditor] >= currentBid[borrower].ammount);
            Tokens = Tokens.add(currentBid[borrower].ammount);
            balances[currentBid[borrower].guarantor] = balances[currentBid[borrower].guarantor].sub(currentBid[borrower].ammount);
            transferFrom(currentBid[borrower].creditor, currentBid[borrower].borrower, currentBid[borrower].ammount);
            currentBid[borrower].issued = true;
        }
    }

    function returnCredit(address borrower) public {
        require(currentBid[borrower].borrower == borrower);
        if (currentBid[borrower].issued) {
            balances[currentBid[borrower].borrower] = balances[currentBid[borrower].borrower].sub(currentBid[borrower].ammount);
            balances[currentBid[borrower].creditor] = balances[currentBid[borrower].creditor].sub(currentBid[borrower].ammount);
            Tokens = Tokens.sub(currentBid[borrower].ammount);
            balances[currentBid[borrower].guarantor] = balances[currentBid[borrower].guarantor].add(currentBid[borrower].ammount);
            currentBid[borrower].borrower = 0x0;
            currentBid[borrower].ammount = 0;
            currentBid[borrower].creditor = 0x0;
            currentBid[borrower].guarantor = 0x0;
            currentBid[borrower].accept = false;
            currentBid[borrower].issued = false;
        }
    }
}