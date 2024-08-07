// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
Es uno de las más comunes y peligrosas que suceden, se refiere a situaciones donde un SC realiza
operaciones muy costosas, con lo cual consumen una gran cantidad de recusos de la blockchain. Bucles, recursividad
o incluso contra otros SC que tengan un can coste.
*/
contract CostlyOperations {
    uint256 public constant MAX_ITERATIONS = 1600;

    // en esta funcion sumamos los numeros de forma iterables, el cual si su valor es muy grande, puedo provocar la vulenrabilidad
    function sumarNumsVulnerability() external pure returns (uint256 result) {
        result = 0;

        for (uint256 i = 0; i < MAX_ITERATIONS; i++) {
            result += 1;
        }
    }

    // Si conocemos un mecanismo que puede simplificar la operacion, podemos evitar dicha vulnerabilidad. La importante de calcular el gas
    function sumarNums() external pure returns (uint256 result) {
        return sumNumbers(MAX_ITERATIONS);
    }

    function sumNumbers(uint256 num) internal pure returns (uint256 result) {
        return (num * (num + 1)) / 2;
    }
}
