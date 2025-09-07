% receta(Plato, Duración, Ingredientes)
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

% elabora(Chef, Plato)
elabora(guille, empanadaDeCarneFrita).
elabora(guille, empanadaDeCarneAlHorno).
elabora(vale, rabas).
elabora(vale, tiramisu).
elabora(vale, parrilladaDelMar).
elabora(ale, hamburguesa).
elabora(lu, sushi).
elabora(mar, padThai).

% cocinaEn(Restaurante, Chef)
cocinaEn(pinpun, guille).
cocinaEn(laPececita, vale).
cocinaEn(laParolacha, vale).
cocinaEn(sushiRock, lu).
cocinaEn(olakease, lu).
cocinaEn(guendis, ale).
cocinaEn(cantin, mar).

% tieneEstilo(Restaurante, Estilo)
tieneEstilo(pinpun, bodegon(parqueChas, 6000)).
tieneEstilo(laPececita, bodegon(palermo, 20000)).
tieneEstilo(laParolacha, italiano(15)).
tieneEstilo(sushiRock, oriental(japon)).
tieneEstilo(olakease, oriental(japon)).
tieneEstilo(cantin, oriental(tailandia)).
tieneEstilo(cajaTaco, mexicano([habanero, rocoto])).
tieneEstilo(guendis, comidaRapida(5)).

% italiano(CantidadDePastas)
% oriental(País)
% bodegon(Barrio, PrecioPromedio)
% mexicano(VariedadDeAjies)
% comidaRapida(cantidadDeCombos)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 1: esCrack/1

esCrack(Chef):-
    cocinaEn(UnRestaurante, Chef),
    cocinaEn(OtroRestaurante, Chef),
    UnRestaurante \= OtroRestaurante.

esCrack(Chef):-
    elabora(Chef, padThai).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 2: esOtaku/1

esOtaku(Chef):-
    cocinaEn(_, Chef),
    forall(cocinaEn(UnRestaurante, Chef), tieneEstilo(UnRestaurante, oriental(japon))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 3: esTop/1

esTop(Plato):-
    elabora(_, Plato),
    forall(elabora(Chef, Plato), esCrack(Chef)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 4: esDificil/1

esDificil(Plato):-
    tardaMucho(Plato).

esDificil(Plato):-
    tiene(trufa, Plato).

esDificil(Plato):-
    Plato = souffleDeQueso.

tardaMucho(Plato):-
    receta(Plato, Duracion, _),
    Duracion >= 120.

tiene(Ingrediente, Plato):-
    receta(Plato, _, Ingredientes),
    member(Ingrediente, Ingredientes).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 5: seMereceLaMichelin/1

seMereceLaMichelin(Restaurante):-
    cocinaEn(Restaurante, Chef),
    esCrack(Chef),
    tieneEstiloMichelinero(Restaurante).

tieneEstiloMichelinero(Restaurante):-
    tieneEstilo(Restaurante, Tipo),
    not(Tipo = comidaRapida(_)),
    esMichelinero(Tipo).

esMichelinero(oriental(tailandia)).
esMichelinero(bodegon(palermo, _)).
esMichelinero(italiano(Cantidad)):-
    Cantidad >= 5.
esMichelinero(mexicano(Ajies)):-
    member(habanero, Ajies),
    member(rocoto, Ajies).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 6: tieneMayorRepertorio/2

tieneMayorRepertorio(UnRestaurante, OtroRestaurante):-
    cocinaEn(UnRestaurante, UnChef),
    cocinaEn(OtroRestaurante, OtroChef),
    cantidadDePlatos(UnChef, UnaCantidad),
    cantidadDePlatos(OtroChef, OtraCantidad),
    UnaCantidad > OtraCantidad.

cantidadDePlatos(Chef, Cantidad):-
    findall(Chef, elabora(Chef, UnPlato), ListaDePlatos),
    length(ListaDePlatos, Cantidad).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Punto 7: calificacionGastronomica/2

calificacionGastronomica(Restaurante, Calificacion):-
    cocinaEn(Restaurante, Chef),
    cantidadDePlatos(Chef, Cantidad),
    Calificacion is Cantidad * 5.

