
const { ethers, upgrades } = require("hardhat");

const overrides = {
  gasLimit: 9999999
}


async function main() {
  const filinkAddress = "0x87a3823CAda97EaD026284d90A73549BE3864afB";

  const [signer] = await ethers.getSigners();

  const oracleDAOContractAddress = "0xe3262c0848b0cc5cd43df7139103f1fbf26558cc";
  const contract = await hre.ethers.getContractFactory("FilswanOracle");
  const daoOracleInstance = await contract.attach(oracleDAOContractAddress);

  const tx = await daoOracleInstance.connect(signer).setFilinkOracle(filinkAddress);
  await tx.wait();

  const swanPaymentAddress  = "0x12EDC75CE16d778Dc450960d5f1a744477ee49a0";
  const paymentContract = await hre.ethers.getContractFactory("SwanPayment");
  const paymentInstance = await paymentContract.attach(swanPaymentAddress);

  const tx2 = await paymentInstance.connect(signer).setChainlinkOracle(filinkAddress);
  await tx2.wait();

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });