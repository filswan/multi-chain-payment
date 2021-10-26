//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

import "./interfaces/IPriceFeed.sol";

contract PriceFeed is Initializable, IPriceFeed {

    using SafeMath for uint112;
    using SafeMath for uint256;

    address private _dexPair;
    address private _owner;

    uint8 private _tokenIndex; // can only be 0 or 1

    function initialize(address owner, address dexPair, uint8 tokenIndex) public initializer {
        _owner = owner;
        _dexPair = dexPair;
        _tokenIndex = tokenIndex;
    }

    function consult(
        address token,
        uint256 amount
    ) external 
    override
    view returns (uint256){
        return 0;
        // require(amount>0, "amount must greater than 0");
        //  = _dexPair.call(abi.encodeWithSignature("getReserves()"));

        // uint256 cp = uint(_reserve0).mul(_reserve1).mul(1000**2);
        // uint256 retAmount = 0;

        // if(_tokenIndex == 0){
        //     uint256 tAmt = _reserve0.sub(amount);
        //     require(tAmt>0, "not enough token to return");
        //     uint256 amt = cp.div(tAmt);
        //     retAmount = _reserve1.sub(amt);
        // }else if(_tokenIndex == 1){
        //     uint256 tAmt = _reserve1.sub(amount);
        //     require(tAmt>0, "not enough token to return");
        //     uint256 amt = cp.div(tAmt);
        //     retAmount = _reserve0.sub(amt);
        // }
        // return retAmount;
    }
}