pragma solidity ^0.4.21;

contract Lonation {

	using SafeMath for uint256;
	
	// Address where funds are collected
	address public wallets;
	
	// Amount of wei raised
	uint256 public weiRaised;

	struct Project {
		byte32 public projectName;
		uint public softCap;
		uint public hardCap;
	}


	/**
	* Event for token Fund logging
	* @param Fundr who paid for the tokens
	* @param beneficiary who got the tokens
	* @param value weis paid for Fund
	* @param amount amount of tokens Fundd
	*/

	event TokenTransaction(
		address indexed contributor,
		address indexed beneficiary,
		uint256 value,
		uint256 amount
	);

	/**
	* @param _rate Number of token units a buyer gets per wei
	* @param _wallet Address where collected funds will be forwarded to
	* @param _token Address of the token being sold
	*/
	constructor(uint256 _rate, address _wallet, ERC20 _token) public {
		require(_rate > 0);
		require(_wallet != address(0));
		require(_token != address(0));

		rate = _rate;
		wallet = _wallet;
		token = _token;
	}

	// -----------------------------------------
	// Funding external interface
	// -----------------------------------------

	/**
	* @dev fallback function ***DO NOT OVERRIDE***
	*/
	function () external payable {
		fundingProject(msg.sender);
	}

	/**
	* @dev low level token Fund ***DO NOT OVERRIDE***
	* @param _beneficiary Address performing the token Fund
	*/
	function fundingProject(address _beneficiary) public payable {

		uint256 weiAmount = msg.value;
		_preValidateFund(_beneficiary, weiAmount);

		// calculate token amount to be created
		uint256 tokens = _getTokenAmount(weiAmount);

		// update state
		weiRaised = weiRaised.add(weiAmount);

		_processFund(_beneficiary, tokens);
		
		emit TokenTransaction(
			msg.sender,
			_beneficiary,
			weiAmount,
			tokens
		);

		_updateFundingState(_beneficiary, weiAmount);
		_forwardFunds();
		_postValidateFund(_beneficiary, weiAmount);
	}


	// -----------------------------------------
	// Internal interface (extensible)
	// -----------------------------------------

	/**
	* @dev Validation of an incoming Fund. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
	* @param _beneficiary Address performing the token Fund
	* @param _weiAmount Value in wei involved in the Fund
	*/
	function _preValidateFund(
		address _beneficiary,
		uint256 _weiAmount
	)

		internal
	{
		// optional override
	}

	/**
	* @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
	* @param _beneficiary Address performing the token Fund
	* @param _tokenAmount Number of tokens to be emitted
	*/
	function _deliverTokens(
		address _beneficiary,
		uint256 _tokenAmount
	)
		internal
	{
		token.transfer(_beneficiary, _tokenAmount);
	}

	/**
	* @dev Executed when a Fund has been validated and is ready to be executed. Not necessarily emits/sends tokens.
	* @param _beneficiary Address receiving the tokens
	* @param _tokenAmount Number of tokens to be Fundd
	*/
	function _processFund(
		address _beneficiary,
		uint256 _tokenAmount
	)
		internal
	{
		_deliverTokens(_beneficiary, _tokenAmount);
	}

	/**
	* @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
	* @param _beneficiary Address receiving the tokens
	* @param _weiAmount Value in wei involved in the Fund
	*/
	function _updateFundingState(
		address _beneficiary,
		uint256 _weiAmount
	)
		internal
	{
		// optional override
	}

	/**
	* @dev Override to extend the way in which ether is converted to tokens.
	* @param _weiAmount Value in wei to be converted into tokens
	* @return Number of tokens that can be Fundd with the specified _weiAmount
	*/
	function _getTokenAmount(uint256 _weiAmount)
		internal view returns (uint256)
	{
		return _weiAmount.mul(rate);
	}

	/**
	* @dev Determines how ETH is stored/forwarded on Funds.
	*/
	function _forwardFunds() internal {
		wallet.transfer(msg.value);
	}

}
