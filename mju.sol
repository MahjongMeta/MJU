pragma solidity 0.5.17;

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    require(c >= a, "SafeMath: addition overflow");
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }

    c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Since Solidity automatically asserts when dividing by 0,
    // but we only need it to revert.
    require(b > 0, "SafeMath: division by zero");
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Same reason as `div`.
    require(b > 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

interface IERC20 {
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function totalSupply() external view returns (uint256 _supply);
  function balanceOf(address _owner) external view returns (uint256 _balance);

  function approve(address _spender, uint256 _value) external returns (bool _success);
  function allowance(address _owner, address _spender) external view returns (uint256 _value);

  function transfer(address _to, uint256 _value) external returns (bool _success);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool _success);
}

contract ERC20 is IERC20 {
  using SafeMath for uint256;

  uint256 public totalSupply;
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) internal _allowance;

  function approve(address _spender, uint256 _value) public returns (bool) {
    _approve(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return _allowance[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) public returns (bool _success) {
    _transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
    _transfer(_from, _to, _value);
    _approve(_from, msg.sender, _allowance[_from][msg.sender].sub(_value));
    return true;
  }

  function _approve(address _owner, address _spender, uint256 _amount) internal {
    require(_owner != address(0), "ERC20: approve from the zero address");
    require(_spender != address(0), "ERC20: approve to the zero address");

    _allowance[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
    require(_from != address(0), "ERC20: transfer from the zero address");
    require(_to != address(this), "ERC20: transfer to this contract address");

    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }
}

interface IERC20Detailed {
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
  function decimals() external view returns (uint8 _decimals);
}

contract ERC20Detailed is ERC20, IERC20Detailed {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

contract MarvelousJoyUtilityToken is ERC20Detailed {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
    * @dev Throws if called by any account other than the owner.
    */
  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  constructor()
    public
    ERC20Detailed("Marvelous Joy Utility Token", "MJU", 6)
  {
    _owner = msg.sender;
    totalSupply = uint256(200000).mul(uint256(10)**6);
    balanceOf[msg.sender] = totalSupply;
    emit Transfer(address(0), msg.sender, totalSupply);
  }

  /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }

  /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Internal function without access restriction.
    */
  function _transferOwnership(address newOwner) internal  {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }

  function mint(uint256 _value) public onlyOwner {
    balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
    totalSupply    = totalSupply.add(_value);
    emit Transfer(address(0), msg.sender, _value);
  }

  function burn(uint256 _value) public onlyOwner {
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Transfer(msg.sender, address(0), _value);
  }
}
