// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
Este tipo de vulnerabilidad sucede cuando multiples transactions / procesos acceden a un recurso compartido y estos no tienen
un orden asignado para acceder a dicho recurso. Si lo enfocamos en un contexto para un smart contract,
se puede ver afectado una manipulacion incorrect de la informacion o incluso perdida de fondos
*/

contract RaceCondition {
    uint public balance;
    mapping(address => uint) public balances;

    mapping(address => bool) public isTransfering; // mapping  nos indica si el addres está en la transferencia

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        balance += msg.value;
    }

    function withdrawVulerability(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient funds");

        uint256 oldBalance = balances[msg.sender];

        balances[msg.sender] -= _amount;

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
        require(balances[msg.sender] == oldBalance, "Race Condition detected");
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient funds");

        // verificamos si el usuario está haciendo la transferencia
        require(!isTransfering[msg.sender], "Already in transfer");
        isTransfering[msg.sender] = true; // indicamos que el usuario está haciendo la transferencia

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
        balances[msg.sender] -= _amount;

        // indicamos que el usuario ya no está haciendo la transferencia
        isTransfering[msg.sender] = false;
    }
}
