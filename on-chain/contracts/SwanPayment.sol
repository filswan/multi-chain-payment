//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";
import "./interfaces/IPaymentGateway.sol";
import "./FilecoinOracle.sol";
import "./interfaces/IPriceFeed.sol";

contract SwanPayment is IPaymentMinimal, Initializable {
    address public constant NATIVE_TOKEN =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address private _ERC20_TOKEN;

    address private _owner;
    address private _oracle;
    address private _priceFeed;

    uint256 lockTime = 5 days;
    mapping(string => TxInfo) txMap;

    function initialize(address owner, address ERC20_TOKEN) public initializer {
        _owner = owner;
        _ERC20_TOKEN = ERC20_TOKEN;
    }

    constructor(address owner) public {
        _owner = owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    function setOracle(address oracle) public onlyOwner returns (bool) {
        _oracle = oracle;
        return true;
    }

    function setPricefeedParam(address dexPair, uint8 coinIndex)
        public
        onlyOwner
        returns (bool)
    {
        _oracle = oracle;
        return true;
    }

    // /**
    //  * @dev Throws if called by any account other than the owner.
    //  */
    // modifier onlyParticipant() {
    //     require(_owner == msg.sender, "Caller is not the owner");
    //     _;
    // }

    function getLockedPaymentInfo(string calldata txId)
        public
        view
        override
        returns (TxInfo memory tx)
    {
        // default value is 0
        return txMap[txId];
    }

    event LockPayment(
        string id,
        address token,
        uint256 lockedFee,
        uint256 minPayment,
        address recipient,
        uint256 deadline
    );

    /// @notice Deposits the amount of token for specific transaction
    /// @param param The transaction information for which to deposit balance
    /// @return Returns true for a successful deposit, false for an unsuccessful deposit
    function lockPayment(lockPaymentParam calldata param)
        public
        payable
        override
        returns (bool)
    {
        require(
            !txMap[param.id]._isExisted,
            "Payment of transaction is already locked"
        );
        require(
            param.minPayment > 0 && msg.value > param.minPayment,
            "payment should greater than min payment"
        );
        TxInfo storage t = txMap[param.id];
        t.owner = msg.sender;
        t.minPayment = param.minPayment;
        t.recipient = param.recipient;
        t.deadline = block.timestamp + param.lockTime;
        t.lockedFee = msg.value;
        t._isExisted = true;

        emit LockPayment(
            param.id,
            NATIVE_TOKEN,
            t.lockedFee,
            param.minPayment,
            param.recipient,
            t.deadline
        );
        return true;
    }

    /// @notice Deposits the amount of token for specific transaction
    /// @param param The transaction information for which to deposit balance
    /// @return Returns true for a successful deposit, false for an unsuccessful deposit
    function lockTokenPayment(lockPaymentParam calldata param)
        public
        returns (bool)
    {
        require(
            !txMap[param.id]._isExisted,
            "Payment of transaction is already locked"
        );
        require(
            param.minPayment > 0 && param.amount > param.minPayment,
            "payment should greater than min payment"
        );

        // todo: approve and transfer token into contract.

        TxInfo storage t = txMap[param.id];
        t.owner = msg.sender;
        t.token = param.token;
        t.minPayment = param.minPayment;
        t.recipient = param.recipient;
        t.deadline = block.timestamp + param.lockTime;
        t.lockedFee = param.amount;
        t._isExisted = true;

        emit LockPayment(
            param.id,
            t.token,
            t.lockedFee,
            param.minPayment,
            param.recipient,
            t.deadline
        );
        return true;
    }

    /// @notice Returns the current allowance given to a spender by an owner
    /// @param txId transaction id
    /// @return Returns true for a successful payment, false for an unsuccessful payment
    function unlockPayment(string calldata txId)
        public
        override
        returns (bool)
    {
        TxInfo storage t = txMap[txId];
        require(t._isExisted, "Transaction does not exist");
        require(
            t.owner == msg.sender || t.recipient == msg.sender,
            "Invalid caller"
        );
        // if passed deadline, return payback to user
        if (block.timestamp > t.deadline) {
            require(
                t.owner == msg.sender,
                "Tx passed deadline, only owner can get locked tokens"
            );
            t._isExisted = false;

            payable(address(t.owner)).transfer(t.lockedFee);
        } else {
            uint256 actualFee = FilecoinOracle(_oracle).getPaymentInfo(txId);
            require(actualFee > 0, "Transaction is incompleted");

            // todo: add convert rate function to get latest price

            if (actualFee < t.minPayment) {
                actualFee = t.minPayment;
            }
            t._isExisted = false;

            console.log("actualFee is %s", actualFee);
            console.log("locked fee is %s", t.lockedFee);

            if (t.lockedFee > actualFee) {
                payable(address(t.owner)).transfer(t.lockedFee - actualFee);
            } else {
                actualFee = t.lockedFee;
            }
            payable(address(t.recipient)).transfer(actualFee);
        }
        t.minPayment = 0;
        t.lockedFee = 0;
        // todo: get status from oralce/other contract, status include status, real fee
        // check status, if not complete, return

        return true;
        // real fee is greater than tx.fee, take tx.fee
        // real fee is less than tx.minPayment, take minPayment, return tx.fee - minPayment to tx.owner
        // otherwise, take real fee, return tx.fee - real fee to tx.owner
    }

    /// @notice Returns the current allowance given to a spender by an owner
    /// @param txId transaction id
    /// @return Returns true for a successful payment, false for an unsuccessful payment
    function unlockTokenPayment(
        string cid,
        string orderId,
        string dealId,
        uint256 paid,
        address recipient
    ) public override returns (bool) {
        // todo: should pass cid, orderid, dealid etc into
        TxInfo storage t = txMap[cid];
        require(t._isExisted, "Transaction does not exist");

        // if passed deadline, return payback to user
        if (block.timestamp > t.deadline) {
            require(
                t.owner == msg.sender,
                "Tx passed deadline, only owner can get locked tokens"
            );
            t._isExisted = false;
            t.minPayment = 0;
            t.lockedFee = 0;
            //payable(address(t.owner)).transfer(t.lockedFee);
            IERC20(_ERC20_TOKEN).transfer(t.owner, t.lockedFee);
        } else {
            require(paid > 0, "Transaction is incompleted");

            require(
                FilecoinOracle(_oracle).isPaymentAvailable(
                    cid,
                    orderId,
                    dealId,
                    paid,
                    recipient,
                    true
                ),
                "not enough votes"
            );
            // get latest price
            uint256 tokenAmount = IPriceFeed(_priceFeed).getSwapAmount(paid);

            if (tokenAmount < t.minPayment) {
                tokenAmount = t.minPayment;
            }
            t._isExisted = false;

            console.log("actual token is %s", tokenAmount);

            if (t.lockedFee > tokenAmount) {
                uint256 tmp = t.lockedFee;
                t.lockedFee = 0; // prevent re-entrying
                IERC20(_ERC20_TOKEN).transfer(t.owner, tmp - tokenAmount);
                // payable(address(t.owner)).transfer(t.lockedFee - actualFee);
            } else {
                tokenAmount = t.lockedFee;
                t.lockedFee = 0; // prevent re-entrying
            }
            IERC20(_ERC20_TOKEN).transfer(recipient, tokenAmount);
            // payable(address(t.recipient)).transfer(actualFee);
        }

        return true;
        // real fee is greater than tx.fee, take tx.fee
        // real fee is less than tx.minPayment, take minPayment, return tx.fee - minPayment to tx.owner
        // otherwise, take real fee, return tx.fee - real fee to tx.owner
    }
}
