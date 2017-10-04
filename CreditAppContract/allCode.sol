pragma solidity ^0.4.13;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

    uint256 public Tokens;
    mapping (address => mapping (address => uint256)) allowed;
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract Ownable {
    
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

contract MintableToken is StandardToken, Ownable {

  mapping(address => bool) gotBalance;

  bool public mintingFinished = false;

  event Mint(address indexed sender, uint256 amount);
  
  uint32 public constant TOKENS = 100;

  event MintFinished();

  modifier canMint() {
    require(!gotBalance[msg.sender] && !mintingFinished);
    _;
  }

  function mint() canMint returns (bool) {
    totalSupply = totalSupply.add(TOKENS);
    balances[msg.sender] = balances[msg.sender].add(TOKENS);
    gotBalance[msg.sender] = true;
    Mint(msg.sender, TOKENS);
    return true;
  }

  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}

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

contract SimpleTokenCoin is CreditToken {
    
    string public constant name = "Simple Coint Token";
    
    string public constant symbol = "SCT";
    
    uint32 public constant decimals = 18;
    
}