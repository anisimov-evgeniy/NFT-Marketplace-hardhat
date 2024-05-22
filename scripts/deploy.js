async function main() {
  const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");

  const NFTMarketplace_ = await NFTMarketplace.deploy();

  await NFTMarketplace_.deployed();

  console.log("NFTMarketplace deployed to:", NFTMarketplace_.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
