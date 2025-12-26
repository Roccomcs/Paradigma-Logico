/*
Queremos reflejar que 
Gabriel cree en Campanita, el Mago de Oz y Cavenaghi
Juan cree en el Conejo de Pascua
Macarena cree en los Reyes Magos, el Mago Capria y Campanita
Diego no cree en nadie

Conocemos tres tipos de sueño
ser un cantante y vender una cierta cantidad de “discos” (≅ bajadas)
ser un futbolista y jugar en algún equipo
ganar la lotería apostando una serie de números

Queremos reflejar entonces que
Gabriel quiere ganar la lotería apostando al 5 y al 9, y también quiere ser un futbolista de Arsenal
Juan quiere ser un cantante que venda 100.000 “discos”
Macarena no quiere ganar la lotería, sí ser cantante estilo “Eruca Sativa” y vender 10.000 discos
*/

% cree(Persona,[ListaDePersonajes]).
cree(gabriel,[campanita,magoDeOz,cavenaghi]).
cree(juan,[conejoDePascua]).
cree(macarena,[reyesMagos,magoCapria,campanita]).
cree(diego,[]). 

% tiposDeSuenio(Persona,Tema,Extra).
tiposDeSuenio(gabriel,ganarLaLoteria,[5,9]).
tiposDeSuenio(gabriel,futbolista,arsenal).
tiposDeSuenio(juan,cantante,100000).
tiposDeSuenio(macarena,cantante,10000).

/*
Queremos saber si una persona es ambiciosa, esto ocurre cuando la suma de dificultades de los sueños es mayor a 20. La dificultad de cada sueño se calcula como
6 para ser un cantante que vende más de 500.000 ó 4 en caso contrario
ganar la lotería implica una dificultad de 10 * la cantidad de los números apostados
lograr ser un futbolista tiene una dificultad de 3 en equipo chico o 16 en caso contrario. Arsenal y Aldosivi son equipos chicos.
*/

esAmbiciosa(Persona):-
    tiposDeSuenio(Persona,_,_),
    findall(Dificultad,(tiposDeSuenio(Persona,Tema,_), dificultadDeSuenio(Persona,Tema,Dificultad)), ListaDeDificultades),
    sum_list(ListaDeDificultades, SumaDeDificultades),   
    SumaDeDificultades > 20.

dificultadDeSuenio(Persona,cantante,Dificultad):-
    tiposDeSuenio(Persona,cantante,DiscosVendidos),
    DiscosVendidos > 500000,
    Dificultad is 6.

dificultadDeSuenio(Persona,cantante,Dificultad):-
    tiposDeSuenio(Persona,cantante,DiscosVendidos),
    DiscosVendidos <= 500000,
    Dificultad is 4.

dificultadDeSuenio(Persona,ganarLaLoteria,Dificultad):-
    tiposDeSuenio(Persona,ganarLaLoteria,ListaDeNumeros),
    length(ListaDeNumeros,NumerosApostados),
    Dificultad is 10 * NumerosApostados.

dificultadDeSuenio(Persona,futbolista,Dificultad):-
    tiposDeSuenio(Persona,futbolista,Equipo),
    equipoChico(Equipo),
    Dificultad is 3.

dificultadDeSuenio(Persona,futbolista,Dificultad):-
    tiposDeSuenio(Persona,futbolista,Equipo),
    not(equipoChico(Equipo)),
    Dificultad is 16.

equipoChico(aldosivi).
equipoChico(arsenal).

/*
Queremos saber si un personaje tiene química con una persona. Esto se da
si la persona cree en el personaje y...
para Campanita, la persona debe tener al menos un sueño de dificultad menor a 5.
para el resto, 
todos los sueños deben ser puros (ser futbolista o cantante de menos de 200.000 discos)
y la persona no debe ser ambiciosa
*/

tieneQuimica(Personaje,Persona):-
    cree(Persona,ListaDePersonajes),
    member(Personaje,ListaDePersonajes),
    forall(member(Personaje,ListaDePersonajes), cumpleCondicion(Persona,Personaje)).

cumpleCondicion(Persona,campanita):-
    tiposDeSuenio(Persona,Tema,_),
    dificultadDeSuenio(Persona,Tema,Dificultad),
    Dificultad < 5.

cumpleCondicion(Persona,Personaje):-
    tiposDeSuenio(Persona,futbolista,_),
    not(esAmbiciosa(Persona)).

cumpleCondicion(Persona,Personaje):-
    tiposDeSuenio(Persona,cantante,DiscosVendidos),
    DiscosVendidos < 200000,
    not(esAmbiciosa(Persona)).

/*
Sabemos que
Campanita es amiga de los Reyes Magos y del Conejo de Pascua
el Conejo de Pascua es amigo de Cavenaghi, entre otras amistades

Necesitamos definir si un personaje puede alegrar a una persona, esto ocurre
si una persona tiene algún sueño
el personaje tiene química con la persona y...
el personaje no está enfermo
o algún personaje de backup no está enfermo. Un personaje de backup es un amigo directo o indirecto del personaje principal
*/

% esAmigo(Personaje,OtroPersonaje).
esAmigo(campanita,reyesMagos).
esAmigo(campanita,conejoDePascua).
esAmigo(conejoDePascua,cavenaghi).

puedeAlegrar(Personaje,Persona):-
    tiposDeSuenio(Persona,_,_),
    tieneQuimica(Personaje,Persona),
    (not(estaEnfermo(Personaje)); existeBackupSano(Personaje,[Personaje])). % No esta enfermo o existe un backup sano

% Otra opcion que evita el ; es repetir logica con tipos de sueño y tiene quimica

estaEnfermo(campanita).
estaEnfermo(reyesMagos).
estaEnfermo(conejoDePascua).

existeBackupSano(Personaje, Recursividad):-
    esAmigo(Personaje,OtroPersonaje),
    not(member(OtroPersonaje,Recursividad)),
    (not(estaEnfermo(OtroPersonaje)); existeBackupSano(OtroPersonaje, [OtroPersonaje|Recursividad])).

/*
Explicacion de la recursividad
existeBackupSano(Personaje,Recursividad), busca un amigo del Personaje que no este en la lista de Recursividad (para evitar ciclos).
esAmigo(Personaje,OtroPersonaje), encuentra un amigo del Personaje.
not(member(OtroPersonaje,Recursividad)), asegura que el amigo no haya sido visitado antes.
(not(estaEnfermo(OtroPersonaje)); asegura que si el amigo no esta enfermo, la busqueda termina con exito.
existeBackupSano(OtroPersonaje, [OtroPersonaje|Recursividad])). si el amigo esta enfermo, se llama recursivamente para buscar un amigo del amigo, 
agregando el amigo actual a la lista de Recursividad para evitar ciclos.
*/
