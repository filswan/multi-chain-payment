
const hre = require("hardhat");

async function main() {

 
  const oracleDAOContractAddress = "0x9208C2B417Ec2699454843A06A5E49fA6dd88422";

  const contract = await hre.ethers.getContractFactory("FilswanOracle");
  const daoOracleInstance = await contract.attach(oracleDAOContractAddress);

  // const result = await daoOracleInstance.getCidList('87881',
  // 'filecoin_calibration');
  // console.log(result);

  const result = await daoOracleInstance.getCarPaymentVotes('87893',
    'filecoin_calibration','0xc4fcaAdCb0b00a9501e56215c37B10fAF9e79c0a');
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
