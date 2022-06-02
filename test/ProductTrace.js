const ProductTrace = artifacts.require("ProductTrace");
const utils =  require("./helpers/utils");
const companyNames = ["Twendee Company", "Tomato Company"];
const companyName32Bytes=companyNames.map(p=>web3.utils.asciiToHex(p));
const productNames = ["Tomato", "orange"];
const productName32Bytes = productNames.map(p=>web3.utils.asciiToHex(p));

contract("ProductTrace",(accounts)=>{
    let [alice, bob] = accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await ProductTrace.new();
    });
    it("should be able to create a new new company", async () => {
        // const contractInstance = await ProductTrace.new();
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
    xit("should not allow other address for companies", async () => {
        await utils.shouldThrow(contractInstance.setCompany(bob,companyName32Bytes[0]
            , {from: alice,value:web3.utils.toWei("0.01", "ether")}));
    })

    xcontext("with the single-step transfer scenario", async () => {
        it("should transfer a product", async () => {
            // TODO: Test the single-step transfer scenario.
            const result = await contractInstance.setCompany(alice,companyName32Bytes[0]
                , {from: alice,value:web3.utils.toWei("0.01", "ether")});
            const result2 = await contractInstance.setCompany(bob,companyName32Bytes[1]
                , {from: bob,value:web3.utils.toWei("0.01", "ether")});
            const resultp = await contractInstance.createProduct(1,productName32Bytes[0], alice, true
                , {from: alice,value:web3.utils.toWei("0.01", "ether")});

        })
    })

    xcontext("with the two-step transfer scenario", async () => {
        xit("should approve and then transfer a product when the approved address calls transferFrom", async () => {
            // TODO: Test the two-step scenario.  The approved address calls transferFrom
        })
        it("should approve and then transfer a product when the owner calls transferFrom", async () => {
            // TODO: Test the two-step scenario.  The owner calls transferFrom
        })
    })
    // afterEach(async () => {
    //     await contractInstance.selfDestruct();
    // });
})
