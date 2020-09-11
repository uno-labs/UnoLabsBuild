var assert = require('assert');
const sleep = (waitTimeInMs) => new Promise(resolve => setTimeout(resolve, waitTimeInMs));

function get_result(hash) {
  if (hash.error) {
    throw hash.error;
  }else{
    return hash.data;
  }
}

let Module;

before(async () => {
  Module = require('../UnoSemuxLightCoreWasm.js');
  await sleep(500);
})

describe('Module', () => {
  it ('should have UnoSemuxTransactionType with 7 types', () => {
    assert.equal(Module.UnoSemuxTransactionType.COINBASE.value, 0);
    assert.equal(Module.UnoSemuxTransactionType.TRANSFER.value, 1);
    assert.equal(Module.UnoSemuxTransactionType.DELEGATE.value, 2);
    assert.equal(Module.UnoSemuxTransactionType.VOTE.value, 3);
    assert.equal(Module.UnoSemuxTransactionType.UNVOTE.value, 4);
    assert.equal(Module.UnoSemuxTransactionType.CREATE.value, 5);
    assert.equal(Module.UnoSemuxTransactionType.CALL.value, 6);
  });
});

describe('Wallet', () => {
  let wallet, mnemonic_phrase, hd_group_id, account, address;

  beforeEach(() => {
    wallet = get_result(Module.UnoSemuxWallet.new_wallet());
    mnemonic_phrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon';
    hd_group_id = get_result(wallet.add_hd_group(mnemonic_phrase, ''));
    account = get_result(wallet.generate_next_hd_address(hd_group_id));
    address = get_result(account.address());
  });

  describe('Mnemonic phrases', () => {
    let mnemonic_phrases = [
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon',
      'abandon  abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon',
      ' abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon',
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon ',
    ];

    mnemonic_phrases.forEach(phrase => {
      it ('should generate consistent address `'+phrase+'`', function() {
        if (phrase != mnemonic_phrases[0]) this.skip();
        hd_group_id = get_result(wallet.add_hd_group(phrase, ''));
        account = get_result(wallet.generate_next_hd_address(hd_group_id));
        address = get_result(account.address());
        assert.equal(address, 'd430fd0ddbdab8a767d02c7202dfccd037f97bbb');
      });
    });
    
  });

  describe('Address searching', () => {
    it ('should find HD addresses', () => {
      let found_account = get_result(wallet.find_address(address));
      let found_address = get_result(found_account.address());
      assert.equal(found_address, 'd430fd0ddbdab8a767d02c7202dfccd037f97bbb');
    });
  });

  describe('Serialization/Deserialization', () => {
    let serial;

    beforeEach(() => {
      serial = get_result(wallet.serialize('password'));
    });

    it ('should serialize wallet to hex string', () => {
      assert.equal(serial.length, 438);
    });

    describe('Deserialization', () => {
      let restored_wallet;

      beforeEach(() => {
        restored_wallet = get_result(Module.UnoSemuxWallet.new_wallet())
        restored_wallet.deserialize(serial, 'password');
      });

      it ('should generate random addresses', () => {
        let random_account = get_result(restored_wallet.generate_random_address());
        let random_address = get_result(random_account.address());
        assert(random_address.length, 40);
      });

      it.skip ('should find addresses in deserialized wallet', () => {
        let found_restored_account = get_result(restored_wallet.find_address(address));
        assert.ok(found_restored_account);

        let found_restored_address = get_result(found_restored_account.address());
        assert.equal(found_restored_address, 'd430fd0ddbdab8a767d02c7202dfccd037f97bbb');
      });
    });

  });
});
