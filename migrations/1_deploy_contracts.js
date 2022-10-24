const OnChainScheduler = artifacts.require("OnChainScheduler");

module.exports = function (deployer) {
    deployer.deploy(OnChainScheduler);
};
