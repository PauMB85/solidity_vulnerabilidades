// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
Esta vulnerabilidad consiste en enviar los fondos(ethers o otro token) sin verificar la respuesta de la transacción, 
y pornerse a realizar otras operaciones, pudiendo afectar el balance del contrato o usuario
*/

contract UncheckedSend {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrWithVulnerability(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Vulnerabilidad: se enviar los fondos sin verificar la respuesta de la transacción
        (bool success, ) = payable(msg.sender).call{value: amount}("");

        // nos ponemos ha hacer otras cosas, como por ejemplo: actualizar el balance del usuario
        balances[msg.sender] -= amount;
    }

    function withdry(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // En este caso se verifica la respuesta de la transacción, si falla se lanza la excepcion
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transaction fail");

        balances[msg.sender] -= amount;
    }
}
