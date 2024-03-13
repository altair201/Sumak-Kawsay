const SalesOficialUnity = artifacts.require('SalesOficialUnity');

module.exports = async function (deployer) {
    const unityTokenAddress = '0xA58501cC8bc605B498Cb6AD15DcB835902e0CA54';
    const usdtTokenAddress = '0xbc13c88A984d5B023E6EB4D6BA7547792a0e4ceC';

    await deployer.deploy(SalesOficialUnity, unityTokenAddress, usdtTokenAddress);
}