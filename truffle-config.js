const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
    plugins: ["truffle-plugin-verify"],
    api_keys: {
        polygonscan: '3B4REMUFKBFJYC5P8WVI5WCMHJPMNSU5TV'
    },
    contracts_build_directory: path.join(__dirname, "client/src/contracts"),
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
        },
        amoy: {
            provider: () => new HDWalletProvider(
                'shallow jeans bring fame together inch length near rhythm when cheese furnace',
                "https://polygon-amoy.drpc.org",0
            ),
            from:"0x078Dc6A9d50fa0aBE5A8383D07E355bF6E751C92",
            gas: 4500000,
            gasPrice: 25000000000,
            network_id: 80002,
            confirmations: 10,
            timeoutBlocks: 200,
            skipDryRun: true,
        }
    },
    compilers: {
        solc: {
            version: "0.8.20",
        },
    },
}