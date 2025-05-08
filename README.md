# PulseStrategy Overview


The On-Chain MicroStrategy, But Better

PulseStrategy is an ERC20 token contract that allows users to issue and redeem PLSTR backed by vPLS (Vouch-staked PLS) from PulseChain.

This is a Ethereum defi product designed to have direct synergy with Pulsechain.

The contract incorporates security measures such as reentrancy protection and uses OpenZeppelin's standard libraries for ERC20 functionality and safe token handling.



# Features

Issuance: Users can deposit vPLS to receive PLSTR (-0.5%fee) during the first 180 days.

Half of the 0.5% fee collected by the SC will go to provide liquidity.

Redemption: Users can burn PLSTR to receive a proportional amount of vPLS at any time.



# What's PulseStrategy All About?


The goal of this DeFi product is to grow PulseChain and reward PLSTR holders.

Holding PLSTR connects you directly to PulseChain's success.

Your vPLS continues earning validator rewards from PulseChain even while backing your PLSTR on ETH.

After the 180-day issuance period, the Strategy Controller protocol will kick in and monitor the markets capturing any PLSTR premiums it can.

The SC, if triggered, will issue additional PLSTR after the issuance period to put on secondary markets when PLSTR trades at a premium.

The SC uses any captured premiums to acquire more vPLS to build the reserves and, in doing so, helps to secure the pulsechain network and increase pulsechain bridge tvl.

PLSTR will always be at least 1:1, with the goal to increase the ratio by capturing market premiums. 

The SC can mint up to 100 million PLSTR every 7 days if the requirements are met.


Your participation directly strengthens PulseChain by exposing Ethereum users to PulseChain assets, helping the protocol capture value from Ethereum and bring it to PulseChain.

Contract Details

Token: PLSTR (PulseStrategy)

PLSTR Address: 0x6c1dA678A1B615f673208e74AB3510c22117090e

vPLS from PulseChain Address: 0x0181e249c507d3b454dE2444444f0Bf5dBE72d09

Minimum PLSTR Issuance: 1,005 PLSTR
Issuance Period: 180 days from deployment.

November 1, 2025 issuance closes and then PLSTR can only be acquired on secondary markets.

License
This contract is licensed under the MIT License. See the SPDX-License-Identifier at the top of the contract.

We Welcome Contributions!

Clone the GitHub repository: git clone <repository-url>.

We especially encourage contributions to develop new front-end interfaces to enhance user interaction with the contract.

For questions or support, please contact the maintainers via X: 

@PulseStrategy
