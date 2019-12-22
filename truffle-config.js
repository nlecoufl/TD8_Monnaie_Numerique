module.exports = {

  networks: {
    development: {
      host: "127.0.0.1",     
      port: 7545,            
      network_id: "*",       // Any network (default: none)
      }
  },

  compilers: {
    solc: {
      version: "0.5.0"    // Fetch exact version from solc-bin (default: truffle's version)
    }
  }
  
}