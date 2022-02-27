
const hre = require("hardhat");

async function main() {

 
  const contractAddress = "0x24B9c56BB6419f4c5AE6a63Fd64dE0dCFA1841F1";

  const contract = await hre.ethers.getContractFactory("SwanPayment");
  const instance = await contract.attach(contractAddress);

  const result = await instance.getChainlinkOracle();
  console.log(result);

  const contractAddress1 = "0x9208C2B417Ec2699454843A06A5E49fA6dd88422";

  const contract1 = await hre.ethers.getContractFactory("FilswanOracle");
  const instance1 = await contract1.attach(contractAddress1);

  const result1 = await instance1.getChainlinkOracle();
  console.log(result1);


    // const oracleDAOContractAddress = "0x9208C2B417Ec2699454843A06A5E49fA6dd88422";
  // const contract = await hre.ethers.getContractFactory("FilswanOracle");
  // const daoOracleInstance = await contract.attach(oracleDAOContractAddress);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
