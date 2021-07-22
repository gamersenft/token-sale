// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import "./Ownable.sol";
import "./utils/TransferHelper.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPresaleFactory.sol";
import "./interfaces/IUniswapV2Locker.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";

contract PresaleLockForwarder is Ownable {
    
    IPresaleFactory public PRESALE_FACTORY;
    IUniswapV2Locker public PLATFORM_LOCKER;
    IUniswapV2Factory public UNI_FACTORY;
    
    constructor(address _presaleFactoryAddress) public {
        PRESALE_FACTORY = IPresaleFactory(_presaleFactoryAddress);
        PLATFORM_LOCKER = IUniswapV2Locker(0xaDB2437e6F65682B85F814fBc12FeC0508A7B1D0);
        UNI_FACTORY = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    }

    /**
        Send in _token0 as the PRESALE token, _token1 as the BASE token (usually WETH) for the check to work. As anyone can create a pair,
        and send WETH to it while a presale is running, but no one should have access to the presale token. If they do and they send it to 
        the pair, scewing the initial liquidity, this function will return true
    */
    function uniswapPairIsInitialised (address _token0, address _token1) public view returns (bool) {
        address pairAddress = UNI_FACTORY.getPair(_token0, _token1);
        if (pairAddress == address(0)) {
            return false;
        }
        uint256 balance = IERC20(_token0).balanceOf(pairAddress);
        if (balance > 0) {
            return true;
        }
        return false;
    }
    
    function lockLiquidity (IERC20 _baseToken, IERC20 _saleToken, uint256 _baseAmount, uint256 _saleAmount, uint256 _unlock_date, address payable _withdrawer) external {
        require(PRESALE_FACTORY.presaleIsRegistered(msg.sender), 'PRESALE NOT REGISTERED');
        address pair = UNI_FACTORY.getPair(address(_baseToken), address(_saleToken));
        if (pair == address(0)) {
            UNI_FACTORY.createPair(address(_baseToken), address(_saleToken));
            pair = UNI_FACTORY.getPair(address(_baseToken), address(_saleToken));
        }
        
        TransferHelper.safeTransferFrom(address(_baseToken), msg.sender, address(pair), _baseAmount);
        TransferHelper.safeTransferFrom(address(_saleToken), msg.sender, address(pair), _saleAmount);
        IUniswapV2Pair(pair).mint(address(this));
        uint256 totalLPTokensMinted = IUniswapV2Pair(pair).balanceOf(address(this));
        require(totalLPTokensMinted != 0 , "LP creation failed");
    
        TransferHelper.safeApprove(pair, address(PLATFORM_LOCKER), totalLPTokensMinted);
        uint256 unlock_date = _unlock_date > 9999999999 ? 9999999999 : _unlock_date;
        PLATFORM_LOCKER.lockLPToken(pair, totalLPTokensMinted, unlock_date, payable(0x0), true, _withdrawer);
    }
    
}