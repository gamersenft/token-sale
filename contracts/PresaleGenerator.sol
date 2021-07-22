// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import "./utils/PresaleHelper.sol";
import "./utils/TransferHelper.sol";
import "./interfaces/IPresaleFactory.sol";
import "./interfaces/IPresaleSettings.sol";
import "./interfaces/IERC20.sol";
import "./Ownable.sol";
import "./libraries/SafeMath.sol";
import "./Launchpad.sol";


contract PresaleGenerator is Ownable {

    using SafeMath for uint256;
    IPresaleFactory public presaleFactory;
    IPresaleSettings public presaleSettings;
    address presaleLockForwarder;

    struct PresaleParams {
        uint256 amount;
        uint256 tokenPrice;
        uint256 maxSpendPerBuyer;
        uint256 hardcap;
        uint256 softcap;
        uint256 liquidityPercent;
        uint256 listingRate; // sale token listing price on uniswap
        uint256 startblock;
        uint256 endblock;
        uint256 lockPeriod;
    }

    constructor(address _presaleFactory_address, address _presaleSettings_address, address _presaleLockForwarder) public {
        presaleFactory = IPresaleFactory(_presaleFactory_address);
        presaleSettings = IPresaleSettings(_presaleSettings_address);
        presaleLockForwarder = _presaleLockForwarder;
    }

    /**
     * @notice Creates a new Presale contract and registers it in the PresaleFactory.sol.
     */
    function createPresale (
      address payable _presaleOwner,
      IERC20 _presaleToken,
      IERC20 _baseToken,
      uint256[10] memory uint_params
      ) public payable {
        
        PresaleParams memory params;
        params.amount = uint_params[0];
        params.tokenPrice = uint_params[1];
        params.maxSpendPerBuyer = uint_params[2];
        params.hardcap = uint_params[3];
        params.softcap = uint_params[4];
        params.liquidityPercent = uint_params[5];
        params.listingRate = uint_params[6];
        params.startblock = uint_params[7];
        params.endblock = uint_params[8];
        params.lockPeriod = uint_params[9];
        
        if (params.lockPeriod < 4 weeks) {
            params.lockPeriod = 4 weeks;
        }
        
        // Charge ETH fee for contract creation
        require(msg.value == presaleSettings.getEthCreationFee(), 'FEE NOT MET');
        presaleSettings.getEthAddress().transfer(presaleSettings.getEthCreationFee());
        
        require(params.amount >= 10000, 'MIN DIVIS'); // minimum divisibility
        require(params.endblock.sub(params.startblock) <= presaleSettings.getMaxPresaleLength());
        require(params.tokenPrice.mul(params.hardcap) > 0, 'INVALID PARAMS'); // ensure no overflow for future calculations
        require(params.liquidityPercent >= 300 && params.liquidityPercent <= 1000, 'MIN LIQUIDITY'); // 30% minimum liquidity lock
        
        uint256 tokensRequiredForPresale = PresaleHelper.calculateAmountRequired(params.amount, params.tokenPrice, params.listingRate, params.liquidityPercent, presaleSettings.getTokenFee());
      
        Launchpad newLaunchpad = new Launchpad(address(this), address(presaleSettings), presaleLockForwarder);
        TransferHelper.safeTransferFrom(address(_presaleToken), address(msg.sender), address(newLaunchpad), tokensRequiredForPresale);
        newLaunchpad.init1(_presaleOwner, params.amount, params.tokenPrice, params.maxSpendPerBuyer, params.hardcap, params.softcap, 
        params.liquidityPercent, params.listingRate, params.startblock, params.endblock, params.lockPeriod);
        newLaunchpad.init2(_baseToken, _presaleToken, presaleSettings.getBaseFee(), presaleSettings.getTokenFee(), presaleSettings.getEthAddress(), presaleSettings.getTokenAddress());
        presaleFactory.registerPresale(address(newLaunchpad));
    }

}