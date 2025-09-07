%receta(Plato,Duracion,Igredientes).
receta(empanadaDeCarneFrita, 20, [harina, carne, cebolla, picante, aceite]).
receta(empanadaDeCarneAlHorno, 20, [harina, carne, cebolla, picante]).
receta(lomoALaWellington, 125, [lomo, hojaldre, huevo, mostaza]).
receta(pastaTrufada, 40, [spaghetti, crema, trufa]).
receta(souffleDeQueso, 35, [harina, manteca, leche, queso]).
receta(tiramisu, 30, [vainillas, cafe, mascarpone]).
receta(rabas, 20, [calamar, harina, sal]).
receta(parrilladaDelMar, 40, [salmon, langostinos, mejillones]).
receta(sushi, 30, [arroz, salmon, sesamo, algaNori]).
receta(hamburguesa, 15, [carne, pan, cheddar, huevo, panceta, trufa]).
receta(padThai, 40, [fideos, langostinos, vegetales]).

%elabora(Chef,Plato).
elabora(guille, empanadaDeCarneFrita).
elabora(guille, empanadaDeCarneAlHorno).
elabora(vale, rabas).
elabora(vale, tiramisu).
elabora(vale, parrilladaDelMar).
elabora(ale, hamburguesa).
elabora(lu, sushi).
elabora(mar, padThai).

% cocinaEn(Restaurante,Chef).
cocinaEn(pinpun, guille).
cocinaEn(laPececita, vale).
cocinaEn(laParolacha, vale).
cocinaEn(sushiRock, lu).
cocinaEn(olakease, lu).
cocinaEn(guendis, ale).
cocinaEn(cantin, mar).

%tieneEstilo(Restaurante,Estilo).
tieneEstilo(pinpun, bodegon(parqueChas, 6000)).
tieneEstilo(laPececita, bodegon(palermo, 20000)).
tieneEstilo(laParolacha, italiano(15)).
tieneEstilo(sushiRock, oriental(japon)).
tieneEstilo(olakease, oriental(japon)).
tieneEstilo(cantin, oriental(tailandia)).
tieneEstilo(cajaTaco, mexicano([habanero, rocoto])).
tieneEstilo(guendis, comidaRapida(5)).


% Posibles estilos
% italiano(CantidadDePastas).
% oriental(Pais).
% bodegon(Barrio,PrecioPromedio).
% mexicano(variedadDeAjies).
% comidaRapida(CantidadDeCombos).

% 1 esCrack/1: un o una chef es crack si trabaja en por lo menos dos restaurantes o cocina pad thai.

esCrack(Chef):-
    cocinaEn(UnRestaurante,Chef),
    cocinaEn(OtroRestaurante,Chef),
    UnRestaurante \= OtroRestaurante.

esCrack(Chef):-
    elabora(Chef,padThai).

% 2 esOtaku/1: un o una chef es otaku cuando solo trabaja en restaurantes de comida japonesa.

esOtaku(Chef):-
    cocinaEn(_,Chef),
    forall(cocinaEn(Restaurante,Chef),tieneEstilo(Restaurante,oriental(japon))).

% 3 esTop/1: un plato es top si sólo lo elaboran chefs cracks.

esTop(Plato):-
    elabora(_,Plato),
    forall(elabora(Chef,Plato),esCrack(Chef)).

% 4 esDificil/1: un plato es difícil cuando tiene una duración de más de dos horas o tiene trufa como ingrediente o es un soufflé de queso.

esDificil(Plato):-
    receta(Plato,_,_),
    unaFuncion(Plato).

unaFuncion(Plato):-
    receta(Plato,Duracion,_),
    Duracion > 120.

unaFuncion(Plato):-
    receta(Plato,_,Ingredientes),
    member(trufa,Ingredientes).

% Otra Forma de poner que tiene trufa
/*
esDificil(Plato):-
    tiene(trufa, Plato).

tiene(Ingrediente, Plato):-
    receta(Plato, _, Ingredientes),
    member(Ingrediente, Ingredientes).
*/

esDificil(souffleDeQueso).

/* 5 seMereceLaMichelin/1: un restaurante se merece la estrella Michelin cuando tiene un o una chef crack y su estilo de cocina es michelinero. 
Esto sucede cuando es un restaurante:
a)de comida oriental de Tailandia,
b)un bodegón de Palermo,
c)italiano de más de 5 pastas,
d)mexicano que cocine, por lo menos, con ají habanero y rocoto,
e)los de comida rápida nunca serán michelineros. */

seMereceLaMichelin(Restaurante):-
    cocinaEn(Restaurante,Chef),
    esCrack(Chef),
    tieneEstilo(Restaurante,Estilo),
    estiloMichelinero(Estilo).

estiloMichelinero(oriental(tailandia)).
estiloMichelinero(bodegon(palermo,_)).

estiloMichelinero(italiano(Pastas)):-
    Pastas > 5.

estiloMichelinero(mexicano(Ajies)):-
    member(habanero,Ajies),
    member(rocoto,AJies).

% 6 tieneMayorRepertorio/2: según dos restaurantes, se cumple cuando el primero tiene un o una chef que elabora más platos que el o la chef del segundo.

tieneMayorRepertorio(UnRestaurante,OtroRestaurante):-
    cantidadDePlatos(UnRestaurante,Cantidad1),
    cantidadDePlatos(OtroRestaurante,Cantidad2),
    Cantidad1 > Cantidad2.

cantidadDePlatos(Restaurante,Cantidad):-
    cocinaEn(Restaurante,Chef),
    findall(Plato,elabora(Chef,Plato),Platos),
    length(Platos,Cantidad).

% 7 calificacionGastronomica/2: la calificación de un restaurante es 5 veces la cantidad de platos que elabora el o la chef de este restaurante. 

calificacionGastronomica(Restaurante,Calificacion):-
    cantidadDePlatos(Restaurante,Cantidad),
    Calificacion is Cantidad * 5.