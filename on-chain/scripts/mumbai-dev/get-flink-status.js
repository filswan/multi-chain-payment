
const hre = require("hardhat");

async function main() {

 
  const contractAddress = "0xF321263880dC8fd98dcFE67567E64Fa47e85e24F";
  // const contractAddress = "0xdE810bd96D370fe876858b2cc9B7448Dae855Df0";
  
  const contract = await hre.ethers.getContractFactory("FilinkConsumer");
  const instance = await contract.attach(contractAddress);

  // const result = await instance.getCidList('87881',
  // 'filecoin_calibration');
  // console.log(result);

  const result = await instance.getPrice('58160','filecoin_mainnet');
    console.log(result);

  // const hasRole = await daoOracleInstance.connect(signer).hasRole(
  //   role,
  //   addressList[0]);

  // console.log(hasRole);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
