const TomatoChain = artifacts.require("TomatoChain");
const utils =  require("./helpers/utils");
const companyNames = ["Twendee Company", "Tomato Company"];
const companyName32Bytes=companyNames.map(p=>web3.utils.asciiToHex(p));
const productNames = ["Tomato", "orange"];
const productName32Bytes = productNames.map(p=>web3.utils.asciiToHex(p));

contract("TomatoChain",(accounts)=>{
    let [alice, bob] = accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await TomatoChain.new();
    });
    it("should be able to create a new new company", async () => {
        // const contractInstance = await TomatoChain.new();
        const result = await contractInstance.setCompany(alice,companyName32Bytes[0]
            , {from: alice,value:web3.utils.toWei("0.01", "ether")});
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[1].args.company[1],companyName32Bytes[0]);
    })
    //add new and update same function
    xit("should not allow two companies", async () => {
        await contractInstance.setCompany(alice,companyName32Bytes[0]
            , {from: alice,value:web3.utils.toWei("0.01", "ether")});
        await utils.shouldThrow(contractInstance.setCompany(alice,companyName32Bytes[1]
            , {from: alice,value:web3.utils.toWei("0.01", "ether")}));
    })
    it("should not allow other address for companies", async () => {
        await utils.shouldThrow(contractInstance.setCompany(bob,companyName32Bytes[0]
            , {from: alice,value:web3.utils.toWei("0.01", "ether")}));
    })

})
