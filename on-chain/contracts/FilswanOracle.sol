//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

contract FilswanOracle is Initializable {
    struct TxOracleInfo {
        uint256 paid;
        uint256 terms;
        address recipient;
        bool status;
        bool flag; // check existence of signature
    }

    struct TxOracleStatus {
        uint8 paid;
        uint8 terms;
    }

    address private _owner;
    address private _admin;
    address[] private _daoUsers;

    mapping(string => mapping(address => TxOracleStatus)) txStatusMap;

    mapping(string => mapping(address => TxOracleInfo)) txInfoMap;

    mapping(bytes => uint8) txVoteMap;

    uint8 private _threshold;

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

    function concatenate(
        string memory s1,
        string memory s2,
        string memory s3
    ) private pure returns (string memory) {
        return string(abi.encodePacked(s1, s2, s3));
    }

    function setDAOUsers(address[] calldata daoUsers)
        public
        onlyOwner
        returns (bool)
    {
        _daoUsers = daoUsers;
        return true;
    }

    function signTransaction(
        string cid,
        string orderId,
        string dealId,
        uint256 paid,
        address recipient,
        uint256 terms, // todo: may remove this one
        bool status
    ) public onlyDAOUser {
        string key = concatenate(cid, orderId, dealId);

        require(
            txInfoMap[key][msg.sender].flag == false,
            "You already sign this transaction"
        );

        txInfoMap[key][msg.sender].recipient = recipient;
        txInfoMap[key][msg.sender].paid = paid;
        txInfoMap[key][msg.sender].terms = terms;
        txInfoMap[key][msg.sender].status = status;
        txInfoMap[key][msg.sender].flag = true;

        bytes32 voteKey = keccak256(
            abi.encodePacked(cid, orderId, dealId, paid, recipient, status)
        );

        txVoteMap[voteKey] = txVoteMap[voteKey] + 1;

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

    function isPaymentAvailable(
        string cid,
        string orderId,
        string dealId,
        uint256 paid,
        address recipient,
        bool status
    ) public view returns (bool) {
        bytes32 voteKey = keccak256(
            abi.encodePacked(cid, orderId, dealId, paid, recipient, status)
        );
        return txVoteMap[voteKey] >= _threshold;
    }

    //     function getPaymentInfo(string calldata txId)
    //         public
    //         view
    //         returns (uint256 actualPaid, address recipient)
    //     {
    //         // default value is 0
    //         // todo: every oracle should update the same actual paid.
    //         mapping(address => TxOracleStatus) storage status = statusMap[txId];
    //         for (uint8 i = 0; i < _daoUsers.length; i++) {
    //             if (status[_daoUsers[i]].actualPaid == 0) {
    //                 return 0;
    //             }
    //         }

    //         return status[_daoUsers[0]].actualPaid;
    //     }
}
