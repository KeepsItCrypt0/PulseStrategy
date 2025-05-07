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
    error NotStrategyController();
    error IssuancePeriodEnded();
    error IssuancePeriodActive();
    error InvalidTokenDecimals();
    error MintingLimitExceeded();
    error InsufficientContractBalance();
    error CannotRecoverVPLS();

    // ================ State Variables ================
    address private immutable stakedPLS = 0x0181e249c507d3b454dE2444444f0Bf5dBE72d09;
    address private _strategyController;
    uint256 private immutable deploymentTime;
    uint256 private lastMintTime;

    uint16 private constant STRATEGY_FEE_BASIS_POINTS = 50;
    uint256 private constant MIN_SHARE_AMOUNT = 1000e18;
    uint256 private constant ISSUANCE_PERIOD = 180 days;
    uint256 private constant MINT_COOLDOWN = 7 days;
    uint256 private constant MAX_MINT_PER_PERIOD = 100_000_000e18;

    // ================ Events ================
    event SharesIssued(address indexed buyer, uint256 shares, uint256 fee);
    event SharesRedeemed(address indexed redeemer, uint256 shares, uint256 stakedPLS);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SharesMinted(address indexed strategyController, uint256 amount, uint256 timestamp);
    event StakedPLSDeposited(address indexed strategyController, uint256 amount, uint256 timestamp);
    event TokensRecovered(address indexed token, address indexed recipient, uint256 amount, uint256 timestamp);

    // ================ Constructor ================
    constructor() ERC20("PulseStrategy", "PLSTR") {
        if (IERC20Metadata(stakedPLS).decimals() != 18) revert InvalidTokenDecimals();
        _strategyController = msg.sender;
        deploymentTime = block.timestamp;
        lastMintTime = block.timestamp;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ================ Modifiers ================
    modifier onlyStrategyController() {
        if (msg.sender != _strategyController) revert NotStrategyController();
        _;
    }

    // ================ Internal Functions ================
    function _calculateRedeemableStakedPLS(
        uint256 shareAmount,
        uint256 contractBalance,
        uint256 totalShares
    ) internal pure returns (uint256) {
        if (shareAmount == 0 || totalShares == 0) return 0;
        return (shareAmount * contractBalance) / totalShares;
    }

    // ================ Strategy Functions ================
    function issueShares(uint256 totalAmount) external nonReentrant {
        if (block.timestamp > deploymentTime + ISSUANCE_PERIOD) revert IssuancePeriodEnded();
        if (totalAmount == 0) revert ZeroAmount();
        uint256 fee = (totalAmount * STRATEGY_FEE_BASIS_POINTS) / 10000;
        uint256 shares = totalAmount - fee;
        if (shares < MIN_SHARE_AMOUNT) revert BelowMinimumShareAmount();
        IERC20(stakedPLS).safeTransferFrom(msg.sender, address(this), totalAmount);
        if (fee > 0) IERC20(stakedPLS).safeTransfer(_strategyController, fee);
        _mint(msg.sender, shares);
        emit SharesIssued(msg.sender, shares, fee);
    }

    function redeemShares(uint256 amount) external nonReentrant {
        if (amount <= 0) revert ZeroAmount();
        if (balanceOf(msg.sender) < amount) revert InsufficientBalance();
        uint256 totalShares = totalSupply();
        if (totalShares == 0) revert ZeroSupply();
        uint256 contractBalance = IERC20(stakedPLS).balanceOf(address(this));
        uint256 stakedPLSAmount = _calculateRedeemableStakedPLS(amount, contractBalance, totalShares);
        if (stakedPLSAmount == 0) revert InsufficientContractBalance();
        _burn(msg.sender, amount);
        IERC20(stakedPLS).safeTransfer(msg.sender, stakedPLSAmount);
        emit SharesRedeemed(msg.sender, amount, stakedPLSAmount);
    }

    // ================ Admin Functions ================
    function depositStakedPLS(uint256 amount) external onlyStrategyController nonReentrant {
        if (amount <= 0) revert ZeroAmount();
        IERC20(stakedPLS).safeTransferFrom(msg.sender, address(this), amount);
        emit StakedPLSDeposited(msg.sender, amount, block.timestamp);
    }

    function mintShares(uint256 amount) external onlyStrategyController {
        if (block.timestamp <= deploymentTime + ISSUANCE_PERIOD) revert IssuancePeriodActive();
        if (amount <= 0) revert ZeroAmount();
        if (amount < MIN_SHARE_AMOUNT) revert BelowMinimumShareAmount();
        if (amount > MAX_MINT_PER_PERIOD) revert MintingLimitExceeded();
        if (block.timestamp < lastMintTime + MINT_COOLDOWN) revert MintingLimitExceeded();
        lastMintTime = block.timestamp;
        _mint(_strategyController, amount);
        emit SharesMinted(_strategyController, amount, block.timestamp);
    }

    function recoverTokens(address token, address recipient, uint256 amount) external onlyStrategyController nonReentrant {
        if (token == stakedPLS) revert CannotRecoverVPLS();
        if (recipient == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (IERC20(token).balanceOf(address(this)) < amount) revert InsufficientBalance();
        IERC20(token).safeTransfer(recipient, amount);
        emit TokensRecovered(token, recipient, amount, block.timestamp);
    }

    function transferOwnership(address newController) external onlyStrategyController {
        if (newController == address(0)) revert ZeroAddress();
        address previousOwner = _strategyController;
        _strategyController = newController;
        emit OwnershipTransferred(previousOwner, newController);
    }

    // ================ View Functions ================
    function calculateSharesReceived(uint256 totalAmount) public pure returns (uint256 shares, uint256 fee) {
        fee = (totalAmount * STRATEGY_FEE_BASIS_POINTS) / 10000;
        shares = totalAmount - fee;
        return (shares, fee);
    }

    function getUserShareInfo(address user) external view returns (uint256 shareBalance) {
        shareBalance = balanceOf(user);
    }

    function getContractInfo() external view returns (
        uint256 contractBalance,
        uint256 remainingIssuancePeriod
    ) {
        contractBalance = IERC20(stakedPLS).balanceOf(address(this));
        remainingIssuancePeriod = block.timestamp < deploymentTime + ISSUANCE_PERIOD
            ? deploymentTime + ISSUANCE_PERIOD - block.timestamp
            : 0;
    }

    function getOwnerMintInfo() external view onlyStrategyController returns (uint256 nextMintTime) {
        nextMintTime = block.timestamp < lastMintTime + MINT_COOLDOWN
            ? lastMintTime + MINT_COOLDOWN
            : block.timestamp;
    }

    function getRedeemableStakedPLS(address user, uint256 shareAmount) external view returns (uint256) {
        if (shareAmount == 0 || balanceOf(user) < shareAmount) return 0;
        uint256 totalShares = totalSupply();
        if (totalShares == 0) return 0;
        uint256 contractBalance = IERC20(stakedPLS).balanceOf(address(this));
        return _calculateRedeemableStakedPLS(shareAmount, contractBalance, totalShares);
    }

    function getVPLSBackingRatio() external view returns (uint256) {
        uint256 totalShares = totalSupply();
        if (totalShares == 0) return 0;
        uint256 contractBalance = IERC20(stakedPLS).balanceOf(address(this));
        return (contractBalance * 1e18) / totalShares;
    }

    function owner() external view returns (address) {
        return _strategyController;
    }
}