// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
la vulnerabilidad de reentrancia es una de las más famosas y peligrosas en contratos inteligentes, 
y fue la causa del infame hackeo de The DAO en 2016. La reentrancia ocurre cuando un contrato realiza una 
llamada a un contrato externo antes de que todas las modificaciones de estado necesarias se hayan completado. 
Esto permite que el contrato externo vuelva a llamar a la función original antes de que la primera llamada 
haya terminado, llevando a una posible manipulación del estado del contrato original.


En este SC en la funcion "withdraw", se nos presenta dicha vulnerabilidad porque primero envía 
Ether al solicitante (msg.sender.call{value: amount}("");) antes de actualizar el saldo del 
solicitante (balances[msg.sender] -= amount). Esto permite que el solicitante vuelva a llamar a 
la función withdraw dentro de su propia función fallback o receive, retirando más fondos de los que tiene.
*/

contract ReentrancyVulnerable {
    mapping(address => uint256) public balances;

    // Function to deposit Ether
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Function to withdraw Ether
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "No hay suficientes fondos");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transferencia fallida");

        balances[msg.sender] -= amount;
    }

    // Fallback function to receive Ether
    fallback() external payable {}
    receive() external payable {}
}

// COMO EVITAR ESTE ATAQUE

/**
Incluimos la estrategia reentrancy y utilizar el patron Checks-Effects-Interactions, lo que significa 
que debemos realizar todas las verificaciones y actualizaciones de estado antes de interactuar con otros SC

1. El modificador nonReentrant previene que la función sea llamada recursivamente. Usa una variable booleana 
para rastrear el estado de entrada/salida de la función.

2. El saldo del usuario se actualiza (balances[msg.sender] -= amount;) antes de realizar la llamada externa para 
transferir Ether. Esto asegura que cualquier reentrancia subsiguiente no podrá manipular los saldos incorrectamente.
*/

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

contract ReentrancyFixed is ReentrancyGuard {
    mapping(address => uint256) public balances;

    // Function to deposit Ether
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Function to withdraw Ether with reentrancy protection
    function withdraw(uint256 amount) public nonReentrant {
        require(balances[msg.sender] >= amount, "No hay suficientes fondos");

        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transferencia fallida");
    }

    // Fallback function to receive Ether
    fallback() external payable {}
    receive() external payable {}
}
