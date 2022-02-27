
const hre = require("hardhat");

const overrides = {
  gasLimit: 9999999
}

async function main() {

  const [singer] = await ethers.getSigners();
 
  const contractAddress = "0x24B9c56BB6419f4c5AE6a63Fd64dE0dCFA1841F1";

  const contract = await hre.ethers.getContractFactory("SwanPayment");
  const instance = await contract.attach(contractAddress);

  const recipient = "0xc4fcaAdCb0b00a9501e56215c37B10fAF9e79c0a";
  const network = "filecoin_calibration";
  const deal = "87881";

  const tx = await instance.connect(singer).unlockCarPayment(deal, network, recipient, overrides);
  await tx.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
