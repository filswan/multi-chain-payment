
const { ethers, upgrades } = require("hardhat");

const uniswapv2FactoryABI = require('@uniswap/v2-core/build/IUniswapV2Factory.json').abi;
const sushiswapFactoryAddress = "0xc35DADB65012eC5796536bD9864eD8773aBc74C4";

async function main() {
  const provider = ethers.getDefaultProvider("http://localhost:8545");

    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const swanOracleContract = await ethers.getContractFactory("FilswanOracle");

    const swanPaymentContract = await ethers.getContractFactory("SwanPayment");


    const swanOracleInstance = await upgrades.deployProxy(swanOracleContract, 
      deployer.address, 
      deployer.address, 
      3 // threshold 3, at least 3
      );
    await swanOracleInstance.deployed();

    console.log(`swanOracleInstance address: ${swanOracleInstance.address}`)

    // todo: need to deploy mumbai uniswap contract

    // const sushiFactoryContract = new ethers.Contract(sushiswapFactoryAddress, uniswapv2FactoryABI, provider);
    // const pairAddress = await sushiFactoryContract.getPair(USDCInstance.address, wFilInstance.address);

    // if(pairAddress === "0x0000000000000000000000000000000000000000") {
    //   console.log("Pair not found");
    // }else {
    //   console.log(`Pair address: ${pairAddress}`);
    // }

    const priceFeedContract = await ethers.getContractFactory("PriceOracleFeed");
      // todo: add tokenA and tokenB address
    const priceOracleFeedInstance = await upgrades.deployProxy(priceFeedContract, sushiswapFactoryAddress, );
    await priceOracleFeedInstance.deployed();
    console.log(`priceOracleFeedInstance address: ${priceOracleFeedInstance.address}`);


    // todo: deploy wFil contract on mumbai
    const swanPaymentInstance = await upgrades.deployProxy(swanPaymentContract, deployer.address);
    await swanPaymentInstance.deployed();
    console.log(`swanPaymentInstance address: ${swanPaymentInstance.address}`)

    // const contract = await ethers.getContractFactory("SwanPayment");
    // const paymentInstance = await contract.deploy(deployer.address);
    // console.log("paymentInstance address:", paymentInstance.address);
    // await paymentInstance.deployed();

    // console.log('deploy oracle instance')
    // const oracleContract = await ethers.getContractFactory("FilecoinOracle");
    // oracleInstance = await oracleContract.deploy(deployer.address);
    // await oracleInstance.deployed();
    // console.log("oracleInstance address:", oracleInstance.address);
    // await oracleInstance.setDAOUsers([deployer.address]);

    // console.log('set oracle')
    // await paymentInstance.setOracle(oracleInstance.address);




  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });