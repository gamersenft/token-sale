import { ContractFactory } from "@ethersproject/contracts"

const { ethers } = require('hardhat')


async function deployContract(name: string, args: string[] = [], libraries?: any) {
    let factory: ContractFactory
    console.log(`start deployContract ${name}, ${args}`)

    if (typeof libraries === 'object') {
        // @ts-ignores
        factory = await ethers.getContractFactory(name, libraries)
    } else {
        // @ts-ignores
        factory = await ethers.getContractFactory(name)
    }

    // If we had constructor arguments, they would be passed into deploy()
    const contract= await factory.deploy(...args)

    // The address the Contract WILL have once mined
    console.log(`contract ${name} address ${contract.address}`)

    // The transaction that was sent to the network to deploy the Contract
    console.log(
        `contract ${name} deploy transaction hash ${contract.deployTransaction.hash}`
    )

    // The contract is NOT deployed yet; we must wait until it is mined
    await contract.deployed()
    console.log(`finished deploying ${name} Contract`)
    console.log('=======================================')

    return contract
}

async function main() {
    
    const {address: presaleHelperAddress} = await deployContract('PresaleHelper')
    const {address: presaleFactoryAddress} = await deployContract('PresaleFactory')
    const {address: presaleLockForwarderAddress} = await deployContract('PresaleLockForwarder', [presaleFactoryAddress])
    const {address: presaleSettingsAddress} = await deployContract('PresaleSettings')
    await deployContract('PresaleGenerator', [presaleFactoryAddress, presaleSettingsAddress, presaleLockForwarderAddress], {
        libraries: {
            PresaleHelper: presaleHelperAddress
        }
    })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
