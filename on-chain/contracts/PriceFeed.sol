//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

contract PriceFeed is Initializable, IPriceFeed {


    address private dexPair;
    address private _owner;

    function initialize(address owner) public initializer {
        _owner = owner;
    }


    function getSwapAmount(
        address token1,
        address token2,
        uint256 amount1,
        uint256 amount2
    ) external view returns (uint256){
        (uint112 _reserve1, uint112 _reserve2, uint32 _blockTimestampLast) = dexPair.call(abi.encodeWithSignature("getReserves()"));
        uint256 cp = uint(_reserve0).mul(_reserve1).mul(1000**2);
        if(amount1 > 0){
            uint256 amt = cp.div(_reserve1.sub(amount1));
        }else{
            uint256 amt = cp.div(_reserve2.sub(amount2));
        }
        return 
    }
}