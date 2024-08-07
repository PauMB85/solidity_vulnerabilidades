// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
En este tipo de vulnerabilidades lo que se prentende es interrumpir un servcio para que funcione correctamente
 */

contract DenialOfService {
    uint256 constant MAX_ITERATIONS = 100;

    function attack(uint256 _iterations) public pure {
        for (uint256 i = 0; i < _iterations; i++) {
            uint[] memory data = new uint[](_iterations);

            for (uint256 j = 0; j < _iterations; j++) {
                data[j] = j;
            }
        }
    }

    /**
    una forma de previnir es limitar el numero de acciones.
    En este caso se limita el array para que no se exceda el limite.

    
    */
    function avoidAttack(uint256 _iterations) public pure {
        require(
            _iterations <= MAX_ITERATIONS,
            "Iterations must be less than MAX_ITERATIONS"
        );

        for (uint256 i = 0; i < _iterations; i++) {
            uint[] memory data = new uint[](_iterations);

            for (uint256 j = 0; j < _iterations; j++) {
                data[j] = j;
            }
        }
    }

    /**
    El contrato tiene un bucle for en la función distribute, que recorre todos los oferentes en la lista bidders. 
    Si la lista de oferentes crece demasiado (por ejemplo, miles de oferentes), 
    la transacción puede superar el límite de gas y fallar.

    Aqui el atancante puede registras muchas direcciones haciendo crecer el array de bindders y po lo tanto,
    cuando se ejecute la funcion distribute se quede sin gass y por lo tanto, nadie puede recibir el pago
     */

    address[] public biddersVul;
    mapping(address => uint256) public bidsVul;

    // Función para enviar ofertas
    function bidVulnerability() public payable {
        require(msg.value > 0, "Offer must be greater than zero");
        bidsVul[msg.sender] += msg.value;
        biddersVul.push(msg.sender);
    }

    function distributeVulnerability() public {
        uint256 totalAmount = address(this).balance;
        uint256 numBidders = biddersVul.length;

        for (uint256 i = 0; i < numBidders; i++) {
            address bidder = biddersVul[i];
            uint256 amount = (totalAmount * bidsVul[bidder]) / totalAmount;
            if (amount > 0) {
                (bool success, ) = payable(bidder).call{value: amount}("");
                require(success, "Transfer failed");
            }
        }
    }

    /**
    Para solucionar este caso, lo que se puede hacer es queda uno reclame su cantidad
     */
    mapping(address => uint256) public bids;

    // Función para enviar ofertas
    function bid() public payable {
        require(msg.value > 0, "Offer must be greater than zero");
        bids[msg.sender] += msg.value;
    }

    function claim() public {
        uint256 amount = bids[msg.sender];
        require(amount > 0, "No funds to claim");

        bids[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }
}
