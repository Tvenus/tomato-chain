const TomatoChain = artifacts.require("TomatoChain");

module.exports = function (deployer) {
  deployer.deploy(TomatoChain);
};
