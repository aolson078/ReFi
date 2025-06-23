// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @title DonationPool
 * @notice Minimal donation pool that accepts ETH and USDC contributions and
 *         routes its balance once a day to a hard-coded NGO address.
 */
contract DonationPool {
    /// @dev The environmental NGO receiving all donations.
    address public constant NGO = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @dev The USDC token contract.
    IERC20 public immutable usdc;

    /// @dev Timestamp of the previous withdrawal.
    uint256 public lastWithdraw;

    /// @dev Cumulative totals for accounting / front-end display.
    uint256 public totalEthReceived;
    uint256 public totalUsdcReceived;

    /// @dev Running total of CO2 tonnes funded via donations. This is updated
    ///      when funds are routed to the NGO. A toy constant conversion rate is
    ///      used for simplicity.
    uint256 public totalFundedTonnes;

    /// @dev Emitted when ETH is donated.
    event DonateETH(address indexed from, uint256 amount);

    /// @dev Emitted when USDC is donated.
    event DonateUSDC(address indexed from, uint256 amount);

    /// @dev Emitted when a withdrawal occurs.
    event Withdraw(uint256 ethAmount, uint256 usdcAmount);

    /**
     * @param usdcAddress Address of the USDC token.
     */
    constructor(address usdcAddress) {
        usdc = IERC20(usdcAddress);
        lastWithdraw = block.timestamp;
    }

    /**
     * @notice Donate ETH to the pool.
     */
    receive() external payable {
        totalEthReceived += msg.value;
        emit DonateETH(msg.sender, msg.value);
    }

    /**
     * @notice Donate USDC to the pool.
     * @param amount Amount of USDC to transfer from the sender.
     */
    function donateUSDC(uint256 amount) external {
        require(usdc.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
        totalUsdcReceived += amount;
        emit DonateUSDC(msg.sender, amount);
    }

    /**
     * @notice Withdraw all funds to the NGO address. Can be called by anyone
     *         once per day. Updates CO2 counter using a dummy conversion.
     */
    function withdraw() external {
        require(block.timestamp >= lastWithdraw + 1 days, "Withdrawal too early");

        uint256 ethBalance = address(this).balance;
        uint256 usdcBalance = usdc.balanceOf(address(this));
        require(ethBalance > 0 || usdcBalance > 0, "Nothing to withdraw");

        lastWithdraw = block.timestamp;

        // Update funded CO2 using a toy conversion: 1 ETH == 1 tonne, 1000 USDC == 1 tonne.
        if (ethBalance > 0) {
            totalFundedTonnes += ethBalance / 1 ether;
            payable(NGO).transfer(ethBalance);
        }
        if (usdcBalance > 0) {
            totalFundedTonnes += usdcBalance / 1_000e6; // USDC has 6 decimals
            usdc.transfer(NGO, usdcBalance);
        }

        emit Withdraw(ethBalance, usdcBalance);
    }

    /**
     * @notice Return the current pool balances.
     */
    function poolBalances() external view returns (uint256 ethBalance, uint256 usdcBalance) {
        ethBalance = address(this).balance;
        usdcBalance = usdc.balanceOf(address(this));
    }
}
