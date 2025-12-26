/*
Sabemos que Dodain se va a Pehuenia, San Martín (de los Andes), Esquel, Sarmiento, Camarones y Playas Doradas. Alf, en cambio, se va a Bariloche, San Martín de los Andes y El Bolsón. Nico se va a Mar del Plata, como siempre. Y Vale se va para Calafate y El Bolsón.

Además Martu se va donde vayan Nico y Alf. 
Juan no sabe si va a ir a Villa Gesell o a Federación
Carlos no se va a tomar vacaciones por ahora
*/

% seVa(Persona,ListaDeLugares).
seVa(dodain,[villaPehuenia,sanMartin,esquel,sarmiento,camarones,playasDoradas]).
seVa(alf,[bariloche,sanMartin,elBolson]).
seVa(nico,[marDelPlata]).
seVa(vale,[calafate,elBolson]).

seVa(martu,ListaDeLugares):-
    seVa(nico,ListaDeLugares).
seVa(martu,ListaDeLugares):-
    seVa(alf,ListaDeLugares).

% duda(Persona,ListaDeLugares).
duda(juan,[villaGessel,federacion]).

/*
Incorporamos ahora información sobre las atracciones de cada lugar. Las atracciones se dividen en
un parque nacional, donde sabemos su nombre
un cerro, sabemos su nombre y la altura
un cuerpo de agua (cuerpoAgua, río, laguna, arroyo), sabemos si se puede pescar y la temperatura promedio del agua
una playa: tenemos la diferencia promedio de marea baja y alta
una excursión: sabemos su nombre
Agregue hechos a la base de conocimientos de ejemplo para dejar en claro cómo modelaría las atracciones. Por ejemplo: Esquel tiene como atracciones un parque nacional (Los Alerces) y dos excursiones (Trochita y Trevelin). Villa Pehuenia tiene como atracciones un cerro (Batea Mahuida de 2.000 m) y dos cuerpos de agua (Moquehue, donde se puede pescar y tiene 14 grados de temperatura promedio y Aluminé, donde se puede pescar y tiene 19 grados de temperatura promedio).

*/

% parqueNacional(Nombre).
% cerro(Nombre,Altura).
% cuerpoDeAgua(Nombre,sePuedePescar,temperaturaPromedio).
% playa(Nombre,diferenciaMareas).
% excursion(Nombre).

esquel(parqueNacional(losAlerces),excursion(trochita),excursion(trevelin)).
villaPehuenia(cerro(bateaMahuida,2000),cuerpoDeAgua(moquehue,si,14),cuerpoDeAgua(alumine,si,19)).

/*
Queremos saber qué vacaciones fueron copadas para una persona. Esto ocurre cuando todos los lugares a visitar tienen por lo menos una atracción copada. 
un cerro es copado si tiene más de 2000 metros
un cuerpoAgua es copado si se puede pescar o la temperatura es mayor a 20
una playa es copada si la diferencia de mareas es menor a 5
una excursión que tenga más de 7 letras es copado
cualquier parque nacional es copado
*/

vacacionesCopadas(Persona):-
    seVa(Persona,ListaDeLugares),
    forall(member(Lugar,ListaDeLugares), tieneAtraccionCopada(Lugar)).

tieneAtraccionCopada(cerro(_,Altura)):- Altura > 2000.

tieneAtraccionCopada(cuerpoDeAgua(_,si,_)).

tieneAtraccionCopada(cuerpoDeAgua(_,_,Temperatura)):- Temperatura > 20.

tieneAtraccionCopada(playa(_,Diferencia)):- Diferencia < 5.

tieneAtraccionCopada(excursion(Nombre)):-
    atom_length(Nombre, CantidadDeLetras),
    CantidadDeLetras > 7.

tieneAtraccionCopada(parqueNacional(_)).

% Cuando dos personas distintas no coinciden en ningún lugar como destino decimos que no se cruzaron. Por ejemplo, Dodain no se cruzó con Nico ni con Vale (sí con Alf en San Martín de los Andes). Vale no se cruzó con Dodain ni con Nico (sí con Alf en El Bolsón). El predicado debe ser completamente inversible.

noSeCruzaron(Persona,OtraPersona):-
    seVa(Persona,ListaDeLugares),
    seVa(OtraPersona,OtraListaDeLugares),
    Persona \= OtraPersona,  
    not(compartenLugar(ListaDeLugares,OtraListaDeLugares)).

compartenLugar(ListaDeLugares,OtraListaDeLugares):-
    member(Lugar,ListaDeLugares),
    member(Lugar,OtraListaDeLugares).

% costoDeVida(Destino,Costo). [Tabla del enunciado]
costoDeVida(sarmiento, 100).
costoDeVida(esquel, 150).
costoDeVida(villaPehuenia, 180).
costoDeVida(sanMartin, 150).       
costoDeVida(camarones, 135).
costoDeVida(playasDoradas, 170).
costoDeVida(bariloche, 140).
costoDeVida(calafate, 240).        
costoDeVida(elBolson, 145).
costoDeVida(marDelPlata, 140).

% Queremos saber si unas vacaciones fueron gasoleras para una persona. Esto ocurre si todos los destinos son gasoleros, es decir, tienen un costo de vida menor a 160. Alf, Nico y Martu hicieron vacaciones gasoleras.
vacacionesGasoleras(Persona):-
    seVa(Persona,ListaDeLugares),
    forall(member(Lugar,ListaDeLugares), esDestinoGasolero(Lugar)).

esDestinoGasolero(Lugar):- 
    costoDeVida(Lugar, Costo),
    Costo < 160.

/*
Queremos conocer todas las formas de armar el itinerario de un viaje para una persona sin importar el recorrido. Para eso todos los destinos tienen que aparecer en la solución (no pueden quedar destinos sin visitar).
Por ejemplo, para Alf las opciones son
[bariloche, sanMartin, elBolson]
[bariloche, elBolson, sanMartin]
[sanMartin, bariloche, elBolson]
[sanMartin, elBolson, bariloche]
[elBolson, bariloche, sanMartin]
[elBolson, sanMartin, bariloche]
*/
itinerariosPosibles(Persona,Itinerario):-
    seVa(Persona,ListaDeLugares),
    permutation(ListaDeLugares,Itinerario). 



% permutation permite generar todas las listas posibles con los mismos elementos de la lista original.