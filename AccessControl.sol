// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
Este tipo de vulnerabilidades sucede por a falta de restricciones adecuadas en funciones críticas, 
permitiendo que usuarios no autorizados puedan ejecutar estas funciones y potencialmente causar daños 
al contrato o a sus usuarios. Este tipo de vulnerabilidad es crucial de evitar ya que compromete la seguridad 
y funcionalidad del contrato.
*/

contract AccessControlIssue {
    mapping(address => uint256) private balances;

    // Function to update balances
    function updateBalance(address user, uint256 newBalance) public {
        balances[user] = newBalance;
    }

    // Function to withdraw all funds
    function withdrawAll() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // Function to deposit funds
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Fallback function to receive Ether
    fallback() external payable {}
    receive() external payable {}
}

/**
En nuestro SC cualquiera puede ejecutar la actualización del balance y realizar la retirada de dicho fondo,
Para evitar este problema, se puede utilizar un mecanismo de control para que solo puedo realizar el owner
del contrato dichas operaciones. En este caso creamos una variable PRIVADA del owner del contrato 
y en las funciones criticas se debe verificar quien realiza la operacion
*/

contract AccessControlFixed {
    address private owner;
    mapping(address => uint256) private balances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Solo el owner puede ejecutar esta funcion"
        );
        _;
    }

    // Function to update balances
    function updateBalance(address user, uint256 newBalance) public onlyOwner {
        balances[user] = newBalance;
    }

    // Function to withdraw all funds
    function withdrawAll() public onlyOwner {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        balances[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // Function to deposit funds
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Fallback function to receive Ether
    fallback() external payable {}
    receive() external payable {}
}
