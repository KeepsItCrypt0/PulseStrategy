// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract PulseStrategy is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ================ Custom Errors ================
    error ZeroAmount();
    error BelowMinimumShareAmount();
    error InsufficientBalance();
    error ZeroSupply();
    error ZeroAddress();
    error IssuancePeriodEnded();
    error InsufficientContractBalance();
    error InvalidTokenDecimals();

    // ================ State Variables ================
    address private immutable PLSX = 0x95B303987A60C71504D99Aa1b13B4DA07b0790ab;
    address private immutable strategyController = 0x6aaE8556C69b795b561CB75ca83aF6187d2F0AF5;
    uint256 private immutable deploymentTime;
    uint256 private totalMinted; // Tracks total shares minted
    uint256 private totalPLSXFromUsers; // Tracks PLSX from user deposits

    uint16 private constant STRATEGY_FEE_BASIS_POINTS = 500; // 5% fee for issuance
    uint16 private constant TRANSFER_TAX_BASIS_POINTS = 500; // 5% tax on transfers
    uint16 private constant BURN_SHARE_BASIS_POINTS = 250; // 25% of tax burned
    uint16 private constant RECIPIENT_SHARE_BASIS_POINTS = 750; // 75% of tax to strategy controller
    uint256 private constant MIN_SHARE_AMOUNT = 1000e18;
    uint256 private constant ISSUANCE_PERIOD = 120 days; // 120 days

    // ================ Events ================
    event SharesIssued(
        address indexed buyer, 
        uint256 shares, 
        uint256 totalFee, 
        uint256 feeToContract, 
        uint256 feeToRecipient, 
        uint256 sharesToRecipient
    );
    event SharesRedeemed(address indexed redeemer, uint256 shares, uint256 plsxAmount);
    event TransferTaxApplied(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 tax,
        uint256 burned,
        uint256 toRecipient
    );

    // ================ Constructor ================
    constructor() ERC20("PulseStrategy", "xBOND") {
        if (IERC20Metadata(PLSX).decimals() != 18) revert InvalidTokenDecimals();
        if (strategyController == address(0)) revert ZeroAddress();
        deploymentTime = block.timestamp;
    }

    // ================ Internal Functions ================
    function _calculateRedeemablePLSX(
        uint256 shareAmount,
        uint256 contractBalance,
        uint256 totalShares
    ) internal pure returns (uint256) {
        if (shareAmount == 0 || totalShares == 0) return 0;
        return (shareAmount * contractBalance) / totalShares;
    }

    // ================ Token Transfer Tax Logic ================
    function _update(address from, address to, uint256 amount) internal virtual override {
        if (from == address(0) || to == address(0)) {
            super._update(from, to, amount);
            return;
        }
        if (from == address(this) || to == address(this) || from == strategyController || to == strategyController) {
            super._update(from, to, amount);
            return;
        }
        uint256 tax = (amount * TRANSFER_TAX_BASIS_POINTS) / 10000;
        uint256 amountAfterTax = amount - tax;
        uint256 burnAmount = (tax * BURN_SHARE_BASIS_POINTS) / 10000;
        uint256 recipientAmount = tax - burnAmount;
        if (burnAmount > 0) {
            super._update(from, address(0), burnAmount);
        }
        if (recipientAmount > 0) {
            super._update(from, strategyController, recipientAmount);
        }
        super._update(from, to, amountAfterTax);
        emit TransferTaxApplied(from, to, amount, tax, burnAmount, recipientAmount);
    }

    // ================ Strategy Functions ================
    function issueShares(uint256 totalAmount) external nonReentrant {
        if (block.timestamp > deploymentTime + ISSUANCE_PERIOD) revert IssuancePeriodEnded();
        if (totalAmount == 0) revert ZeroAmount();
        uint256 totalFee = (totalAmount * STRATEGY_FEE_BASIS_POINTS) / 10000;
        uint256 shares = totalAmount - totalFee;
        if (shares < MIN_SHARE_AMOUNT) revert BelowMinimumShareAmount();
        uint256 feeToContract = totalFee / 2;
        uint256 feeToRecipient = totalFee - feeToContract;
        uint256 sharesToRecipient = feeToRecipient;
        IERC20(PLSX).safeTransferFrom(msg.sender, address(this), totalAmount);
        totalPLSXFromUsers += totalAmount - feeToRecipient; // Track user-deposited PLSX
        if (feeToRecipient > 0) IERC20(PLSX).safeTransfer(strategyController, feeToRecipient);
        _mint(msg.sender, shares);
        totalMinted += shares;
        if (sharesToRecipient > 0) {
            _mint(strategyController, sharesToRecipient);
            totalMinted += sharesToRecipient;
        }
        emit SharesIssued(msg.sender, shares, totalFee, feeToContract, feeToRecipient, sharesToRecipient);
    }

    function redeemShares(uint256 amount) external nonReentrant {
        if (amount <= 0) revert ZeroAmount();
        if (balanceOf(msg.sender) < amount) revert InsufficientBalance();
        uint256 totalShares = totalSupply();
        if (totalShares == 0) revert ZeroSupply();
        uint256 contractBalance = IERC20(PLSX).balanceOf(address(this));
        uint256 plsxAmount = _calculateRedeemablePLSX(amount, contractBalance, totalShares);
        if (plsxAmount == 0) revert InsufficientContractBalance();
        _burn(msg.sender, amount);
        IERC20(PLSX).safeTransfer(msg.sender, plsxAmount);
        emit SharesRedeemed(msg.sender, amount, plsxAmount);
    }

    // ================ View Functions ================
    function calculateSharesReceived(uint256 totalAmount) public pure returns (
        uint256 shares, 
        uint256 totalFee, 
        uint256 feeToContract, 
        uint256 feeToRecipient, 
        uint256 sharesToRecipient
    ) {
        totalFee = (totalAmount * STRATEGY_FEE_BASIS_POINTS) / 10000;
        shares = totalAmount - totalFee;
        feeToContract = totalFee / 2;
        feeToRecipient = totalFee - feeToContract;
        sharesToRecipient = feeToRecipient;
        return (shares, totalFee, feeToContract, feeToRecipient, sharesToRecipient);
    }

    function getUserShareInfo(address user) external view returns (uint256 shareBalance) {
        shareBalance = balanceOf(user);
    }

    function getContractInfo() external view returns (
        uint256 contractBalance,
        uint256 remainingIssuancePeriod
    ) {
        contractBalance = IERC20(PLSX).balanceOf(address(this));
        remainingIssuancePeriod = block.timestamp < deploymentTime + ISSUANCE_PERIOD
            ? deploymentTime + ISSUANCE_PERIOD - block.timestamp
            : 0;
    }

    function getRedeemablePLSX(address user, uint256 shareAmount) external view returns (uint256) {
        if (shareAmount == 0 || balanceOf(user) < shareAmount) return 0;
        uint256 totalShares = totalSupply();
        if (totalShares == 0) return 0;
        uint256 contractBalance = IERC20(PLSX).balanceOf(address(this));
        return _calculateRedeemablePLSX(shareAmount, contractBalance, totalShares);
    }

    function getStrategyController() external view returns (address) {
        return strategyController;
    }

    function getTotalBurned() external view returns (uint256) {
        return totalMinted - totalSupply();
    }

    function getStrategyControllerHoldings() external view returns (uint256 xBondBalance) {
        return balanceOf(strategyController);
    }

    function getContractMetrics() external view returns (
        uint256 currentTotalSupply,
        uint256 contractPLSXBalance,
        uint256 totalMintedShares,
        uint256 totalBurned,
        uint256 remainingIssuancePeriod
    ) {
        currentTotalSupply = totalSupply(); // Call the ERC20 function
        contractPLSXBalance = IERC20(PLSX).balanceOf(address(this));
        totalMintedShares = totalMinted; // Use the state variable
        totalBurned = totalMinted - currentTotalSupply;
        remainingIssuancePeriod = block.timestamp < deploymentTime + ISSUANCE_PERIOD
            ? deploymentTime + ISSUANCE_PERIOD - block.timestamp
            : 0;
        return (currentTotalSupply, contractPLSXBalance, totalMintedShares, totalBurned, remainingIssuancePeriod);
    }

    function getPLSXReserveContributions() external view returns (uint256 estimatedControllerPLSX) {
        uint256 contractBalance = IERC20(PLSX).balanceOf(address(this));
        return contractBalance > totalPLSXFromUsers ? contractBalance - totalPLSXFromUsers : 0;
    }

    function getContractHealth() external view returns (
        uint256 plsxBackingRatio,
        uint256 controllerSharePercentage
    ) {
        uint256 totalShares = totalSupply();
        plsxBackingRatio = totalShares == 0 ? 0 : (IERC20(PLSX).balanceOf(address(this)) * 1e18) / totalShares;
        uint256 controllerBalance = balanceOf(strategyController);
        controllerSharePercentage = totalShares == 0 ? 0 : (controllerBalance * 1e18) / totalShares;
        return (plsxBackingRatio, controllerSharePercentage);
    }

    function getStrategyControllerActivitySummary() external view returns (
        uint256 xBondBalance,
        uint256 estimatedControllerPLSX
    ) {
        xBondBalance = balanceOf(strategyController);
        uint256 contractBalance = IERC20(PLSX).balanceOf(address(this));
        estimatedControllerPLSX = contractBalance > totalPLSXFromUsers ? contractBalance - totalPLSXFromUsers : 0;
        return (xBondBalance, estimatedControllerPLSX);
    }
}