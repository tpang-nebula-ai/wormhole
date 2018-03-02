module.exports = {
    networks: {
        testnet: {
            host: "127.0.0.1",
            port: 8545,
            network_id: 666
        },
        development: {
            host: "192.168.88.10",
            port: 8545,
            network_id: 250,
            gas: 8000000
        },
        dev_home: {
            host: "127.0.0.1",
            port: 8545,
            network_id: 438
        }
    }
};
