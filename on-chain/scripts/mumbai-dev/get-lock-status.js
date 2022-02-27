
const hre = require("hardhat");

async function main() {

 
  const contractAddress = "0x24B9c56BB6419f4c5AE6a63Fd64dE0dCFA1841F1";

  const contract = await hre.ethers.getContractFactory("SwanPayment");
  const instance = await contract.attach(contractAddress);

  // const result = await instance.getLockedPaymentInfo('QmSJfGwpEN9NJDjG35jB4tH2UUJgGHeeP4RZ9B94SThqiq');
  // console.log(result);

  const result = await instance.getChainlinkOracle();
  console.log(result);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
