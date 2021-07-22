// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import "./Ownable.sol";
import "./libraries/EnumerableSet.sol";
import "./interfaces/IERC20.sol";

contract PresaleSettings is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
        
    struct Settings {
        uint256 BASE_FEE; // base fee divided by 1000
        uint256 TOKEN_FEE; // token fee divided by 1000
        uint256 REFERRAL_FEE; // a referrals percentage of the presale profits divided by 1000
        address payable BASE_FEE_ADDRESS;
        address payable TOKEN_FEE_ADDRESS;
        uint256 BASE_CREATION_FEE; // fee to generate a presale contract on the platform
        uint256 ROUND1_LENGTH; // length of round 1 in blocks
        uint256 MAX_PRESALE_LENGTH; // maximum difference between start and endblock
        address ROUND1_TOKEN; // early access token addr
        uint256 ROUND1_REQUIRED_HOLDINGS; // min amount of tokens required
        
    }
    
    Settings public SETTINGS;
    
    constructor() public {
        SETTINGS.BASE_FEE = 15; // 1.5%
        SETTINGS.TOKEN_FEE = 15; // 1.5%
        SETTINGS.BASE_CREATION_FEE = 5e17;
        SETTINGS.BASE_FEE_ADDRESS = msg.sender;
        SETTINGS.TOKEN_FEE_ADDRESS = msg.sender;
        SETTINGS.ROUND1_LENGTH = 533; // 553 blocks = 2 hours
        SETTINGS.MAX_PRESALE_LENGTH = 93046; // 2 weeks
        SETTINGS.ROUND1_TOKEN = 0x7b9c3df47f3326fbc0674d51dc3eb0f2df29f37f;
        SETTINGS.ROUND1_REQUIRED_HOLDINGS = 10001;
    }
    
    function getRound1Length () external view returns (uint256) {
        return SETTINGS.ROUND1_LENGTH;
    } 

    function getMaxPresaleLength () external view returns (uint256) {
        return SETTINGS.MAX_PRESALE_LENGTH;
    }
    
    function getBaseFee () external view returns (uint256) {
        return SETTINGS.BASE_FEE;
    }
    
    function getTokenFee () external view returns (uint256) {
        return SETTINGS.TOKEN_FEE;
    }
    
    function getReferralFee () external view returns (uint256) {
        return SETTINGS.REFERRAL_FEE;
    }
    
    function getEthCreationFee () external view returns (uint256) {
        return SETTINGS.BASE_CREATION_FEE;
    }
    
    function getEthAddress () external view returns (address payable) {
        return SETTINGS.BASE_FEE_ADDRESS;
    }
    
    function getTokenAddress () external view returns (address payable) {
        return SETTINGS.TOKEN_FEE_ADDRESS;
    }
    
    function setFeeAddresses(address payable _baseAddress, address payable _tokenFeeAddress) external onlyOwner {
        SETTINGS.BASE_FEE_ADDRESS = _baseAddress;
        SETTINGS.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
    }
    
    function setFees(uint256 _baseFee, uint256 _tokenFee, uint256 _ethCreationFee, uint256 _referralFee) external onlyOwner {
        SETTINGS.BASE_FEE = _baseFee;
        SETTINGS.TOKEN_FEE = _tokenFee;
        SETTINGS.REFERRAL_FEE = _referralFee;
        SETTINGS.ETH_CREATION_FEE = _ethCreationFee;
    }
    
    function setRound1Length(uint256 _round1Length) external onlyOwner {
        SETTINGS.ROUND1_LENGTH = _round1Length;
    }

    function setMaxPresaleLength(uint256 _maxLength) external onlyOwner {
        SETTINGS.MAX_PRESALE_LENGTH = _maxLength;
    }
    
    function editEarlyAccessTokens(address _token, uint256 _requiredHoldings) external onlyOwner {
        SETTINGS.ROUND1_TOKEN = _token;
        SETTINGS.ROUND1_REQUIRED_HOLDINGS = _requiredHoldings;
    }
    
    function userHoldsSufficientRound1Token (address _user) external view returns (bool) {
        if (IERC20(SETTINGS.ROUND1_TOKEN).balanceOf(_user) >= SETTINGS.ROUND1_REQUIRED_HOLDINGS) {
              return true;
          }
        return false;
    }

}