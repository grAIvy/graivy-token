var GraivyToken = artifacts.require("./GraivyToken.sol");

module.exports = function(deployer) {
  deployer.deploy(GraivyToken);
};
