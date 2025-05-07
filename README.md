
# PulseStrategy Overview


The On-Chain MicroStrategy, But Better


PulseStrategy is an ERC20 token contract that allows users to issue and redeem PLSTR backed by vPLS (Vouch-staked PLS) from PulseChain.

The contract incorporates security measures such as reentrancy protection and uses OpenZeppelin's standard libraries for ERC20 functionality and safe token handling.

# Features

Issuance: Users can deposit vPLS to receive PLSTR.

Redemption: Users can burn PLSTR to receive a proportional amount of vPLS.

Issuance Period: A 180-day period



# What's PulseStrategy All About?


The goal of this DeFi product is to grow PulseChain and reward PLSTR holders.

Holding PLSTR connects you directly to PulseChain's success.

Your vPLS continues earning validator rewards from PulseChain even while backing your PLSTR.

After the 180-day issuance period, the SC (Strategy Controller, akin to the OA) will monitor the market and capture any PLSTR premiums.

The SC will use any captured premiums to:

Increase PulseChain's bridge TVL.

Acquire more vPLS to secure the network.

Transfer vPLS to Ethereum and reinvest it into vPLS reserves, growing the backing of PLSTR and increasing the proportional amount holders receive upon redemption.

PLSTR will always be at least 1:1, but the goal is to increase the ratio by capturing market premiums. The SC will issue additional PLSTR after the issuance period to sell on secondary markets only when PLSTR trades at a 2x premium or higher.

The SC can mint up to 100 million PLSTR every 7 days if the requirement of PLSTR trading at a 2x premium or above is met.

Liquidity providers could earn significant fees, while the SC's unstoppable actions may offset impermanent loss.

Your participation directly strengthens PulseChain by exposing Ethereum users to PulseChain assets, helping the protocol capture value from Ethereum and bring it to PulseChain.

Contract Details

Token: PLSTR (PulseStrategy)

PLSTR Address: 0x6c1dA678A1B615f673208e74AB3510c22117090e

vPLS Address: 0x0181e249c507d3b454dE2444444f0Bf5dBE72d09

Minimum PLSTR Issuance: 1,000 PLSTR
Issuance Period: 180 days from deployment, around November 1, 2025

License
This contract is licensed under the MIT License. See the SPDX-License-Identifier at the top of the contract.

We Welcome Contributions!

Clone the GitHub repository: git clone <repository-url>.

We especially encourage contributions to develop new front-end interfaces to enhance user interaction with the contract.

For questions or support, please contact the maintainers via X: 

@PulseStrategy
