PulseStrategy Overview

PulseStrategy is an ERC20 token contract that allows users to issue and redeem PLSTR backed by vPLS Vouch staked PLS from PulseChain.

The contract incorporates security measures such as reentrancy protection and uses OpenZeppelin's standard libraries for ERC20 functionality and safe token handling.

Features

• ERC20 Compliance: Implements the ERC20 standard for the PLSTR token with the name "PulseStrategy".

• Issuance: Users can deposit vPLS to receive PLSTR.

• Redemption: Users can burn PLSTR to receive a PROPORTIONAL amount of vPLS.

• Issuance Period: A 180-day period

• Security: Uses OpenZeppelin's ReentrancyGuard and SafeERC20 for secure token operations.

What's PulseStrategy All About?
 
The goal of this defi product is growing PulseChain and rewarding PLSTR holders. 

Holding PLSTR connects you directly to PulseChain's success

 Your vPLS keeps earning validator rewards from PulseChain even while it's backing your PLSTR

- The SC always has a eye on the market and will capture any PLSTR Premiums taking that value to pulsechain rasing bridge TVL and acquiring more vPLS helping to secure the network and sending the vPLS back to ETH an pumping it back into vPLS reserves growing the backing of PLSTR and the PROPORTIONAL amount you get when you redeem.

PLSTR WILL ALWAY BE ATLEAST 1 TO 1
but the goal is to increase the ratio by capturing market premiums by issuing more PLSTR AFTER ISSUANCE to sell on secondary markets ONLY when SC sees its trading at a 2x premium microstrategy style but on chain

 liquidity providers could earn huge fees while the unstoppable actions of the SC could offset any impermanent loss.
 
 Your participation directly helps make PulseChain stronger and more valuable by exposing Ethereum users to pulsechain assets helping the protocol capture value from ETH and bring it to pulsechain 



Contract Details

• Token: PLSTR (PulseStrategy)

• PLSTR Address: 0x6c1dA678A1B615f673208e74AB3510c22117090e

• vPLS Address: 0x0181e249c507d3b454dE2444444f0Bf5dBE72d09

• Minimum PLSTR issuance: 1,000 PLSTR

• Issuance Period: 180 days from deployment. around Nov 1st 2025


Prerequisites

• Solidity Version: 0.8.20

• Dependencies:

• OpenZeppelin Contracts (@openzeppelin/contracts)

• ERC20.sol

• SafeERC20.sol

• ReentrancyGuard.sol

• IERC20Metadata.sol

Install dependencies using npm:
bash
npm install @openzeppelin/contracts
Usage

License
This contract is licensed under the MIT License. See the SPDX-License-Identifier at the top of the contract.


We welcome contributions! To contribute:

• Clone the GitHub repository: git clone <repository-url>.


We especially encourage contributions to develop new front-end interfaces to enhance user interaction with the contract.

For questions or support, please open an issue on this repository or contact the maintainers via 

X @pulseStrategy
