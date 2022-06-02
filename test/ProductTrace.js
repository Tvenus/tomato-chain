const ProductTrace = artifacts.require("ProductTrace");
const utils =  require("./helpers/utils");
const companyNames = ["Twendee Company", "Tomato Company"];
const companyName32Bytes=companyNames.map(p=>web3.utils.padLeft(web3.utils.asciiToHex(p),64));
const productNames = ["Tomato", "orange"];
const productName32Bytes = productNames.map(p=>web3.utils.padLeft(web3.utils.asciiToHex(p),64));
// companyName32Bytes.forEach(c=> console.log(c));
// productName32Bytes.forEach(c=> console.log(c));

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
    it("should not allow other address for companies", async () => {
        await utils.shouldThrow(contractInstance.setCompany(bob,companyName32Bytes[0]
            , {from: alice,value:web3.utils.toWei("0.01", "ether")}));
    })

    context("with the single-step transfer scenario", async () => {
        it("should be able to create a new product", async () => {
            const result = await contractInstance.setCompany(alice, companyName32Bytes[0]
                , {from: alice, value: web3.utils.toWei("0.01", "ether")});
            const result2 = await contractInstance.setCompany(bob, companyName32Bytes[1]
                , {from: bob, value: web3.utils.toWei("0.01", "ether")});
            const proRes = await contractInstance.createProduct(1, productName32Bytes[0], alice, true, companyName32Bytes[0]
                , {from: alice, value: web3.utils.toWei("0.001", "ether")});
            assert.equal(proRes.receipt.status, true);
            // console.log(proRes);
            // console.log(proRes.logs[0].args);
            assert.equal(proRes.logs[0].args.product[1], productName32Bytes[0]);
        })
        it("should transfer a product", async () => {
            const result = await contractInstance.setCompany(alice,companyName32Bytes[0]
                , {from: alice,value:web3.utils.toWei("0.01", "ether")});
            const result2 = await contractInstance.setCompany(bob,companyName32Bytes[1]
                , {from: bob,value:web3.utils.toWei("0.01", "ether")});
            const proRes = await contractInstance.createProduct(1,productName32Bytes[0], alice, true, companyName32Bytes[0]
                , {from: alice,value:web3.utils.toWei("0.001", "ether")});

            const trans = await contractInstance.transferProduct(alice,bob, 1
                , {from: alice});
            assert.equal(trans.receipt.status, true);
            assert.equal(trans.logs[0].args._to,bob);

            await utils.shouldThrow(contractInstance.confirmProduct(1
                , {from: alice}));
            const confirm = await contractInstance.confirmProduct(1
                , {from: bob});
            assert.equal(confirm.receipt.status, true);
            assert.equal(confirm.logs[0].args._to,bob);

        })
    })
    // afterEach(async () => {
    //     await contractInstance.selfDestruct();
    // });
})
