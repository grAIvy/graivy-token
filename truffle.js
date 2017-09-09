module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      from: "0x39620d5f8045bbD8D0ea777ce7fc0A308C6a0A7a", // default address to use
      network_id: 4,
      gas: 4710388 // Gas limit used for deploys
    }
  }
};
