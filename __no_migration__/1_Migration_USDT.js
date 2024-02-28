const USDToken = artifacts.require("USDToken");

module.exports =  function (deployer) {
     deployer.deploy(USDToken);
}