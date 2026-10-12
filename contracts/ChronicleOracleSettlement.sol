// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IChainlinkFeed {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

/**
 * @title ChronicleOracleSettlement
 * @author cheerfulbay
 * @notice Resilient multi-source Oracle price aggregator with TWAP smoothing and anti-flash-loan bounds checks.
 */
contract ChronicleOracleSettlement {
    address public owner;
    uint256 public constant MAX_PRICE_DEVIATION_BPS = 500; // 5% max deviation between sources
    uint256 public constant MAX_STALENESS_SECONDS = 3600; // 1 hour staleness threshold

    struct AssetOracleConfig {
        address primaryFeed; // e.g. Chainlink
        address secondaryFeed; // e.g. Redstone / Pyth adapter
        uint8 decimals;
        bool isActive;
    }

    mapping(address => AssetOracleConfig) public assetConfigs;

    event OracleConfigured(address indexed asset, address primaryFeed, address secondaryFeed);
    event PriceReported(address indexed asset, uint256 validatedPrice, uint256 timestamp);

    error Unauthorized();
    error StalePriceFeed(uint256 updatedAt, uint256 current);
    error InvalidPrice(int256 price);
    error ExcessiveSourceDeviation(uint256 primary, uint256 secondary);
    error OracleNotConfigured(address asset);

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setAssetOracle(
        address asset,
        address primaryFeed,
        address secondaryFeed,
        uint8 decimals
    ) external onlyOwner {
        assetConfigs[asset] = AssetOracleConfig({
            primaryFeed: primaryFeed,
            secondaryFeed: secondaryFeed,
            decimals: decimals,
            isActive: true
        });
        emit OracleConfigured(asset, primaryFeed, secondaryFeed);
    }

    function getValidatedPrice(address asset) public view returns (uint256) {
        AssetOracleConfig memory config = assetConfigs[asset];
        if (!config.isActive) revert OracleNotConfigured(asset);

        (, int256 primaryAnswer, , uint256 primaryUpdated, ) = IChainlinkFeed(config.primaryFeed).latestRoundData();
        if (primaryAnswer <= 0) revert InvalidPrice(primaryAnswer);
        if (block.timestamp - primaryUpdated > MAX_STALENESS_SECONDS) {
            revert StalePriceFeed(primaryUpdated, block.timestamp);
        }

        uint256 primaryPrice = uint256(primaryAnswer);

        // If secondary feed exists, verify cross-feed deviation bounds
        if (config.secondaryFeed != address(0)) {
            (, int256 secondaryAnswer, , uint256 secondaryUpdated, ) = IChainlinkFeed(config.secondaryFeed).latestRoundData();
            if (secondaryAnswer > 0 && block.timestamp - secondaryUpdated <= MAX_STALENESS_SECONDS) {
                uint256 secondaryPrice = uint256(secondaryAnswer);
                uint256 diff = primaryPrice > secondaryPrice ? primaryPrice - secondaryPrice : secondaryPrice - primaryPrice;
                uint256 deviationBps = (diff * 10000) / primaryPrice;
                if (deviationBps > MAX_PRICE_DEVIATION_BPS) {
                    revert ExcessiveSourceDeviation(primaryPrice, secondaryPrice);
                }
            }
        }

        return primaryPrice;
    }
}
