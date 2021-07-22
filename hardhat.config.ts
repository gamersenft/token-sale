import 'dotenv/config'

import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'
import '@nomiclabs/hardhat-etherscan'
import '@openzeppelin/hardhat-upgrades'
import 'hardhat-typechain'

import { HardhatUserConfig } from 'hardhat/types'

const privateKey = process.env.PRIVATE_KEY
const infuraKey = process.env.INFURA_KEY
const rpcURL = process.env.RPC_URL
const config: HardhatUserConfig = {
    defaultNetwork: 'hardhat',
    solidity: {
        compilers: [
            {
                version: '0.8.0',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: '0.6.6',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: '0.6.0',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
            {
                version: '0.5.0',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },{
                version: '0.8.0',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    networks: {
        hardhat: {},
        kovan: {
            url: `https://kovan.infura.io/v3/${infuraKey}`,
            accounts: [`0x${privateKey}`],
            gasPrice: 1000000000,
        },
        rinkeby: {
            url: `https://rinkeby.infura.io/v3/${infuraKey}`,
            accounts: [`0x${privateKey}`],
            gasPrice: 1000000000,
        },
        ropsten: {
            url: `https://ropsten.infura.io/v3/${infuraKey}`,
            accounts: [`0x${privateKey}`],
            gasPrice: 1000000000,
        },
        mainnet: {
            url: `https://mainnet.infura.io/v3/${infuraKey}`,
            accounts: [`0x${privateKey}`],
            gasPrice: 1000000000,
        },
        fantomTestnet: {
            url: rpcURL,
            accounts: [`0x${privateKey}`],
            chainId: 0xfa2
        }
    },
    typechain: {
        outDir: 'typechain',
        target: 'ethers-v5',
    },
}

export default config
