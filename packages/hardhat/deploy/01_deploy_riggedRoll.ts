import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import { DiceGame, RiggedRoll } from "../typechain-types";

const deployRiggedRoll: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  console.log("Deployer address:", deployer);

  // Get the DiceGame contract
  const diceGame: DiceGame = await ethers.getContract("DiceGame", deployer);
  const diceGameAddress = await diceGame.getAddress();
  console.log("DiceGame deployed at:", diceGameAddress);

  // Deploy the RiggedRoll contract with DiceGame address as a constructor argument
  await deploy("RiggedRoll", {
    from: deployer,
    log: true,
    args: [diceGameAddress],
    autoMine: true,
  });

  // Get the newly deployed RiggedRoll contract
  const riggedRoll: RiggedRoll = await ethers.getContract("RiggedRoll", deployer);
  const riggedRollAddress = await riggedRoll.getAddress();
  console.log("RiggedRoll deployed at:", riggedRollAddress);

  // Transfer ownership to a specific address
  try {
    const newOwnerAddress = "0xD8e5EC1bf477D31f95617a274E8E6722BA93f709";  // Replace this with your actual address
    await riggedRoll.transferOwnership(newOwnerAddress);
    console.log(`Ownership transferred to: ${newOwnerAddress}`);
  } catch (err) {
    console.log("Failed to transfer ownership:", err);
  }
};

export default deployRiggedRoll;
deployRiggedRoll.tags = ["RiggedRoll"];
