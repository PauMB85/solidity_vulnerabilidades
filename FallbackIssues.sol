// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
En solidity existe una funcion que se llama "fallback".
Es una función especial que se llama cuando un contrato recibe Ether sin datos o con datos que no coinciden con 
ninguna de las funciones existentes del contrato

La vulnerabilidad "fallback issue", lo que puede suceder es cada vez que el contrato recibe Ether sin datos. 
Si el contrato tiene lógica insegura dentro de la función fallback, un atacante puede enviar repetidamente transacciones
al contrato para explotar esa lógica. En este ejemplo, tenemos un problema de "vulnerabilidad de reentrancia"

Un atacante puede explotar esta vulnerabilidad para hacer que el contrato llame repetidamente a la función fallback, 
incrementando su balance en cada llamada sin que el saldo se actualice correctamente
*/

contract FallbackIssue {
    mapping(address => uint256) private balances;

    fallback() external payable {
        balances[msg.sender] += msg.value;

        (bool success, ) = msg.sender.call{value: msg.value}("");
        require(success, "Transferencia fallida");
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No hay fondos disponibles para retirar");

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transferencia fallida");
    }

    receive() external payable {}
}

// COMO EVITAR ESTE ATAQUE

/**
En este caso, es evitar que el fallback realice transacciones y utilizar una estrategia de reentracy
*/

// Implementación básica de ReentrancyGuard
contract ReentrancyGuard {
    bool private _notEntered;

    constructor() {
        _notEntered = true;
    }

    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}

contract FallbackFixed is ReentrancyGuard {
    mapping(address => uint256) private balances;

    fallback() external payable {
        revert("La funcion fallback no esta habilitada");
    }

    function deposit() public payable nonReentrant {
        balances[msg.sender] += msg.value;

        (bool success, ) = msg.sender.call{value: msg.value}("");
        require(success, "Transferencia fallida");
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No hay fondos disponibles para retirar");

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transferencia fallida");
    }

    receive() external payable {}
}
