const OffChainScheduler = artifacts.require("OffChainScheduler");
const OnChainScheduler = artifacts.require("OnChainScheduler");
const PublicKeyRegistry = artifacts.require("PublicKeyRegistry");

module.exports = function (deployer) {
    deployer.deploy(OffChainScheduler);
    deployer.deploy(OnChainScheduler);
    deployer.deploy(PublicKeyRegistry);
};
