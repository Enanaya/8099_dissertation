pragma solidity ^0.4.18;

library SafeMath {



  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Hexagon {
    using SafeMath for uint256;
  /* Main information */
  string public constant name = "Hexagon";
  string public constant symbol = "HXG";
  uint8 public constant decimals = 4;
  uint8 public constant burnPerTransaction = 2;
  uint256 public constant initialSupply = 420000000000000;
  uint256 public currentSupply = initialSupply;

  /* Create array with balances */
  mapping (address => uint256) public balanceOf;
  /* Create array with allowance */
  mapping (address => mapping (address => uint256)) public allowance;

  /* Constructor */
  function Hexagon() public {
    /* Give creator all initial supply of tokens */
    balanceOf[msg.sender] = initialSupply;
  }

  /* PUBLIC */
  /* Send tokens */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    _transfer(msg.sender, _to, _value);

    return true;
  }

  /* Return current supply */
  function totalSupply() public constant returns (uint) {
    return currentSupply;
  }

  /* Burn tokens */
  function burn(uint256 _value) public returns (bool success) {
    /* Check if the sender has enough */
    require(balanceOf[msg.sender] >= _value);
    /* Subtract from the sender */
    balanceOf[msg.sender] -= _value;
    /* Send to the black hole */
    balanceOf[0x0] += _value;
    /* Update current supply */
    currentSupply -= _value;
    /* Notify network */
    Burn(msg.sender, _value);

    return true;
  }

  /* Allow someone to spend on your behalf */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    /* Check if the sender has already  */
    require(_value == 0 || allowance[msg.sender][_spender] == 0);
    /* Add to allowance  */
    allowance[msg.sender][_spender] = _value;
    /* Notify network */
    Approval(msg.sender, _spender, _value);

    return true;
  }

  /* Transfer tokens from allowance */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    /* Prevent transfer of not allowed tokens */
    require(allowance[_from][msg.sender] >= _value);
    /* Remove tokens from allowance */
    allowance[_from][msg.sender] -= _value;

    _transfer(_from, _to, _value);

    return true;
  }

  /* INTERNAL */
  function _transfer(address _from, address _to, uint _value) internal {
    /* Prevent transfer to 0x0 address. Use burn() instead  */
    require (_to != 0x0);
    /* Check if the sender has enough */
    require (balanceOf[_from] >= _value.add(burnPerTransaction));
    /* Check for overflows */
    require (balanceOf[_to].add( _value) > balanceOf[_to]);
    /* Subtract from the sender */
    balanceOf[_from] -= _value + burnPerTransaction;
    /* Add the same to the recipient */
    balanceOf[_to] += _value;
    /* Apply transaction fee */
    balanceOf[0x0] += burnPerTransaction;
    /* Update current supply */
    currentSupply -= burnPerTransaction;
    /* Notify network */
    Burn(_from, burnPerTransaction);
    /* Notify network */
    Transfer(_from, _to, _value);
  }

  /* Events */
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Burn(address indexed from, uint256 value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}