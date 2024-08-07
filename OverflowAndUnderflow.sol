// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract OverflowAndUnderflow {
    /**
    en este caso la vulnerabilidad de Overflow, se debe a un desbordamiento y ocurre cuando una operacion aritmetica, 
    excede del valor máximo del tipo que puede representar, haciendo que el valor vuelva al valor minimo posible.
    en este caso pasaria otra vez hacia el 0 si "_val" es 1.
    */
    function overflow(uint8 _val) public pure returns (uint8) {
        uint8 maxValue = 255;
        maxValue += _val;
        return maxValue;
    }

    /**
    La vulnerabilida de Underflow, se debe un subdesbordamiento y ocurre cuando una operacion aritmetica, excede del
    valor minimo del tipo que puede representar, haciendo que el valor vuelva al valor maximo posible. en este caso
    si el valor maxValue al ser 0 y _val es 1, el valor vuelve a ser 255.
     */
    function underflow(uint8 _val) public pure returns (uint8) {
        uint8 maxValue = 0;
        maxValue -= _val;
        return maxValue;
    }

    /**
    Para evitar estos errores, se debe utilizar la libreria SafeMath que nos controla el overflow y underflow.
     */

    /**
    NOTA: a parti de la version 0.8.0, se pueden hacer operaciones aritmeticas sin usar la libreria, ya que están controlado
    SafeMat
     */
}
