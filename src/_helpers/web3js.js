let Web3 = require('web3');


   export const web3 = (typeof web3 !== 'undefined') ? 
     new Web3(web3.currentProvider) :
     new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
