const SalesOficialUnity = artifacts.require('SalesOficialUnity');

module.exports = async function (deployer) {
    const unityTokenAddress = '0xfaAA5cD094E8F169D30B65cB6A04477C032D5c08';
    const usdtTokenAddress = '0x1cd1faD975C1aeD270816a5B96215379ec09B02d';

    await deployer.deploy(SalesOficialUnity, unityTokenAddress, usdtTokenAddress);
}