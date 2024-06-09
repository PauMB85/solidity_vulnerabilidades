// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
En solidity al no tener una forma verdaderamente aleatoria para generar números aleatorios, debido a la naturaleza
determinista. Esto puedo llevar a los atacantes a adelanterse al resultado y manipular el contrato en su beneficio.

En el contrato de Randomness se utiliza el timestamp y prevrandom el cual el atacante se puede anticipar
*/

contract Randomness {
    uint private seed;
    uint public randomNumber;

    constructor() {
        seed = block.timestamp;
    }

    function generateRandomNumber() public {
        randomNumber = uint(
            keccak256(abi.encodePacked(block.prevrandao, block.timestamp, seed))
        );
    }
}

// COMO EVITAR ESTE ATAQUE

/**
Una forma de mitigar esta vulnerabilidad es usando un oráculo para obtener un número aleatorio fuera de la cadena de bloques. 
EJEMPLO: Chainlink VRF (Verifiable Random Function) es una solución popular que proporciona números aleatorios verificables
*/

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomSafe is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    constructor()
        VRFConsumerBase(
            0x514910771AF9Ca656af840dff83E8264EcF986CA, // VRF Coordinator
            0x514910771AF9Ca656af840dff83E8264EcF986CA // LINK Token
        )
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a9a120ebdeafaa4966f5;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal override {
        randomResult = randomness;
    }
}
