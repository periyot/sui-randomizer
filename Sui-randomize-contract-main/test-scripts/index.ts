import { getFullnodeUrl, SuiClient } from '@mysten/sui/client'
import { Transaction } from '@mysten/sui/transactions'
import { Ed25519Keypair, Ed25519PublicKey  } from '@mysten/sui/keypairs/ed25519'
import { fromBase64 } from '@mysten/sui/utils';

const rpcUrl = getFullnodeUrl('testnet')
const client = new SuiClient({ url: rpcUrl });

const ownerPrivateKey = 'ACqJrLa3gGqAq659U3nmYXHbUHAMYd3Mxg6xdqAHsSGc'
//const ownerAddress = '0x30fc201e06eb9b9f2e6cd04ef183cb3e245a5571132dd99db8efe061ecb38208'
const buff = fromBase64(ownerPrivateKey)
const keypair = Ed25519Keypair.fromSecretKey(buff.slice(1))
const packageId = '0x92a776b9585e3cfb5e946efb8b08352bdccebe3cc8e1c8fa39aa8fdbab86f303'
const adminCapId = '0x4e440a014458bd89718721257a3c61e1349c6cdbd14d0abc56ee49d1538e68ff'


const main = async ()=>{
  //await create_pool()
  // await deposit_pool()
  await play()
}
const create_pool = async() =>{

  const tx = new Transaction()
  //======testing transfer coin
  // const [coin] = tx.splitCoins(tx.gas, [1000000]);
  // tx.transferObjects([coin], '0x356cc8f397f2b750cd483225c80f25a08fb0fa3150f5c0544db05ef1c22ef70b');

  // const res = await client.signAndExecuteTransaction({ signer: keypair, transaction: tx });
  // console.log(res)
  //========

  //create init_pool
  let adminCap = tx.object(adminCapId)
  //deposit amount
  const [coin] = tx.splitCoins(tx.gas, [100000000]); //SUI coin
  tx.moveCall({
    package: packageId, //deployed package_id
    module: 'buble',
    function: 'init_pool',
    typeArguments: ['0x2::sui::SUI'], //coinType
    arguments:[adminCap, coin]
  })
  //send tx by admin keypair
  const res = await client.signAndExecuteTransaction({ signer: keypair, transaction: tx })
  const transaction = await client.waitForTransaction({
    digest: res.digest,
    options: {
      showEffects: true,
    },
  });
  console.log('created-pool-object-id:', transaction.effects?.created![0].reference.objectId)
}

const deposit_pool = async () =>{
  const poolId = '0x35493f1ca9ad728c35adcfec8861276b2d30f1f4c8cf3aa8b662a0be488a7cd8'
  const tx = new Transaction()
  const [coin] = tx.splitCoins(tx.gas, [100000000]); //SUI coin
  const poolObj = tx.object(poolId)
  tx.moveCall({
    package: packageId, //deployed package_id
    module: 'buble',
    function: 'deposit',
    typeArguments: ['0x2::sui::SUI'], //coinType
    arguments:[poolObj, coin]
  })
  const res = await client.signAndExecuteTransaction({ signer: keypair, transaction: tx })
  const transaction = await client.waitForTransaction({
    digest: res.digest,
    options: {
      showEffects: true,
    },
  });
  console.log(transaction)
  console.log(transaction.effects?.created)
}

const play = async () => {
  const poolId = '0x35493f1ca9ad728c35adcfec8861276b2d30f1f4c8cf3aa8b662a0be488a7cd8'
  const tx = new Transaction()
  const [coin] = tx.splitCoins(tx.gas, [2000000]); //SUI coin
  const poolObj = tx.object(poolId)
  const randomObj = tx.object('0x8') // reserved
  tx.moveCall({
    package: packageId, //deployed package_id
    module: 'buble',
    function: 'play',
    typeArguments: ['0x2::sui::SUI'], //coinType
    arguments:[poolObj, randomObj, coin],
  })
  const gasBudgetAmount = 30000000
  tx.setGasBudget(gasBudgetAmount)
  const res = await client.signAndExecuteTransaction({ signer: keypair, transaction: tx })
  const transaction = await client.waitForTransaction({
    digest: res.digest,
    options: {
      showEffects: true,
    },
  });
  console.log(transaction)
  console.log(transaction.effects?.created)
}
main().catch(e => {
  console.error(e)
})