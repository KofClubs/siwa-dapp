const OffChainScheduler = artifacts.require("OffChainScheduler");
const OnChainScheduler = artifacts.require("OnChainScheduler");

module.exports = function (deployer) {
    deployer.deploy(OffChainScheduler);
    deployer.deploy(OnChainScheduler);
};
