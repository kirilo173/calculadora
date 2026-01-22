<?php

require __DIR__ . '/../vendor/autoload.php';

use Campico\Calculadora\Calculadora;

// Ejemplo simple para sumar números
$calculadora = new Calculadora();
$a = 5;
$b = 3;
echo "La suma de $a y $b es: " . $calculadora->suma($a, $b);