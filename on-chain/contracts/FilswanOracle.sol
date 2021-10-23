//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

contract FilswanOracle is Initializable {

    struct TxOracleStatus {
        uint256 paid;
        uint256 terms;
        address receiving_address;
    }

    address private _owner;
    address private _admin;
    address[] private _daoUsers;
    mapping(string => mapping(address => TxOracleStatus)) statusMap;

    event SignTransaction(
        string cid,
        string orderId,
        string dealId,
        address recipient,
        uint256 paid,
        uint256 terms,
        bool status
    );
    function initialize(address owner) public initializer {
        _owner = owner;
    }

    constructor(address owner) {
        _owner = owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyAdmin() {
        require(_admin == msg.sender, "Caller is not the admin");
        _;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyDAOUser() {
        bool found = false;
        for (uint8 i = 0; i < _daoUsers.length; i++) {
            if (_daoUsers[i] == msg.sender) {
                found = true;
                break;
            }
        }
        require(found, "Caller is not the DAO user");
        _;
    }

    function setDAOUsers(address[] calldata daoUsers)
        public
        onlyOwner
        returns (bool)
    {
        _daoUsers = daoUsers;
        return true;
    }

   function signTransaction(string cid,
        string orderId,
        string dealId,
        uint256 paid,
        address recipient,
        uint256 terms,
        bool status) public onlyDAOUser{
        // todo: combine cid, orderId, dealId as key

        emit SignTransaction(
            cid,
            orderId,
            dealId,
            recipient,
            paid,
            terms,
            status
        );
   }


    function getPaymentInfo(string calldata txId)
        public
        view
        returns (uint256 actualPaid)
    {
        // default value is 0
        // todo: every oracle should update the same actual paid.
        mapping(address => TxOracleStatus) storage status = statusMap[txId];
        for (uint8 i = 0; i < _daoUsers.length; i++) {
            if (status[_daoUsers[i]].actualPaid == 0) {
                return 0;
            }
        }

        return status[_daoUsers[0]].actualPaid;
    }


}
