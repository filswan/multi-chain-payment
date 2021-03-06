
const hre = require("hardhat");

async function main() {

 // todo: change address
  const oracleDAOContractAddress = "0x9208C2B417Ec2699454843A06A5E49fA6dd88422";

  // todo: update addresses
  const addressList = [
    "0x6d2e5279b106843f6E924194401B50e6e27FE12a",
    "0xbE14Eb1ffcA54861D3081560110a45F4A1A9e9c5",
    "0xeA2bf08288bbfB0d3DBf534f35af32bF2c6E5e45"
  ];

  const [signer] = await ethers.getSigners();

  const contract = await hre.ethers.getContractFactory("FilswanOracle");
  const daoOracleInstance = await contract.attach(oracleDAOContractAddress);

  const tx = await daoOracleInstance.connect(signer).setDAOUsers(addressList);
  await tx.wait();

  const role = await daoOracleInstance.DAO_ROLE.call();
  console.log(role);

  const hasRole = await daoOracleInstance.connect(signer).hasRole(
    role,
    addressList[0]);

  console.log(hasRole);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
