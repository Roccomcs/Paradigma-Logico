% pertenece(Gato,Clan)
pertenece(estrellaDeFuego, clanDelTrueno).
pertenece(estrellaAzul, clanDelTrueno).
pertenece(tormentaDeArena, clanDelTrueno).

%gato(Gato, EdadEnLunas, EnemigosALosQueVencio).
gato(estrellaDeFuego, 6, [estrellaRota, patasNegras, corazonDeRoble]).
gato(estrellaAzul, 6, [estrellaRota, patasNegras, estrellaDeFuego]).

%esDe(Clan,Zona).
esDe(clanDelTrueno, granSicomoro).
esDe(clanDelTrueno, rocasDeLasSerpientes).
esDe(clanDelTrueno, hondonadaArenosa).
esDe(clanDelViento, cuatroArboles).
esDe(clanDelRio, rocasSoleadas).
esDe(clanDeLaSombra, vertedero).

%patrulla(Gato,Zona).
patrulla(estrellaDeFuego, rocasSoleadas).
patrulla(estrellaDeFuego, rocasSoleadas).
patrulla(estrellaDeFuego, rocasSoleadas).
patrulla(estrellaDeFuego, rocasSoleadas).
patrulla(estrellaDeFuego, rocasSoleadas).
patrulla(estrellaDeFuego, rocasSoleadas).
patrulla(tormentaDeArena, cuatroArboles).

%posibles presas de los gatos
% ave(TipoDeAve, AltitudDeVuelo).
% pez(OceanoDondeVive).
% rata(Nombre,Profesion,Altura).

%seEncuentra(Presa,Zona).
seEncuentra(ave(paloma,5),cuatroArboles).
seEncuentra(ave(quetzal,15),rocasDeLasSerpientes).
seEncuentra(pez(atlantico),granSicomoro).
seEncuentra(rata(ratattouile,cocinero,15),cocinaParisina).
seEncuentra(rata(pinky,cientifico,22),laboratorio).

% 1. Un gato es un traidor si alguno de los gatos a los que se enfrento es de su mismo clan.
esTraidor(Gato):-
    pertenece(Gato,Clan),
    obtenerEnemigo(Gato,Enemigo),
    pertenece(Enemigo,Clan).

obtenerEnemigo(Gato,Enemigo):-
    gato(Gato,_,Enemigos),
    member(Enemigo,Enemigos).

% 2. Dos gatos se pueden enfrentar si son de distintos clanes y patrullan la misma zona
sePuedenEnfrentar(UnGato,OtroGato):-
    UnGato \= OtroGato,
    sonDeDistintosClanes(UnGato,OtroGato),
    patrullanLaMismaZona(UnGato,OtroGato).

sonDeDistintosClanes(UnGato,OtroGato):-
    pertenece(UnGato,UnClan),
    pertenece(OtroGato,OtroClan),
    UnClan \= OtroClan.

patrullanLaMismaZona(UnGato,OtroGato):-
    patrulla(UnGato,Zona),
    patrulla(OtroGato,Zona).

% 3. Una zona es concurrida si es patrullada por más de 5 gatos o si la zona es cuatroArboles
esConcurrida(Zona):-
    patrulla(_,Zona),
    cantidadDeGatosEnZona(Zona,Cantidad),
    Cantidad > 5.

cantidadDeGatosEnZona(Zona,Cantidad):-
    findall(Gato,patrulla(Gato,Zona),ListaDeGatos),
    length(ListaDeGatos,Cantidad).

esConcurrida(cuatroArboles).

% 4. Un gato es miedoso cuando solo patrulla zonas que le pertenecen a su clan.
esMiedoso(Gato):-
    pertenece(Gato,Clan),
    forall(patrulla(Gato,Zona),esDe(Clan,Zona)).

% 5. Un gato es travieso si todas las zonas que patrulla son concurridas o si tiene menos de 6 lunas de edad o es estrella de fuego.
esTravieso(Gato):-
    pertenece(Gato,_),
    forall(patrulla(Gato,Zona),esConcurrida(Zona)).
    
esTravieso(Gato):-
    gato(Gato,Edad,_),
    Edad < 6.

esTravieso(estrellaDeFuego).

% 6. Un gato puede atrapar a una presa si éste no es miedoso y ademas la presa:
% es un ave que vuela a menos de 10 metros del piso o es una paloma
% es una rata cocinera llamada ratattouile que mide 15 cm
% los peces no pueden ser atrapados

puedeAtrapar(Gato,Presa):-
    gato(Gato,_,_),
    not(esMiedoso(Gato)),
    seEncuentra(Presa,_),
    presaAtrapable(Presa).

presaAtrapable(ave(_,Altura)):-
    Altura < 10.

presaAtrapable(ave(paloma,_)).

presaAtrapable(rata(ratattouile,cocinero,15)).

% 7. La experiencia de un gato es la cantidad de enemigos derrotados por su edad gatuna
experiencia(Gato,Experiencia):-
    gato(Gato,Edad,_),
    enemigosVencidos(Gato,Cantidad),
    Experiencia is Cantidad * Edad.

% 8. Un gato ganó un enfrentamiento a otro gato cuando el primero venció más enemigos que el segundo

ganaUnEnfrentamiento(Gato,OtroGato):-
    enemigosVencidos(Gato,Cantidad),
    enemigosVencidos(OtroGato,OtraCantidad),
    Cantidad > OtraCantidad.

enemigosVencidos(Gato,Cantidad):-
    gato(Gato,_,Enemigos),
    length(Enemigos,Cantidad).
