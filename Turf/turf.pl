/* Punto 1: Pasos al costado (2 puntos)
Les jockeys son personas que montan el caballo en la carrera: tenemos a Valdivieso, que mide 155 cms y pesa 52 kilos, Leguisamo, que mide 161 cms y pesa 49 kilos, 
Lezcano, que mide 149 cms y pesa 50 kilos, Baratucci, que mide 153 cms y pesa 55 kilos, Falero, que mide 157 cms y pesa 52 kilos.

También tenemos a los caballos: Botafogo, Old Man, Enérgica, Mat Boy y Yatasto, entre otros. Cada caballo tiene sus preferencias:
a Botafogo le gusta que le jockey pese menos de 52 kilos o que sea Baratucci
a Old Man le gusta que le jockey sea alguna persona de muchas letras (más de 7), existe el predicado atom_length/2
a Enérgica le gustan todes les jockeys que no le gusten a Botafogo
a Mat Boy le gusta les jockeys que midan mas de 170 cms
a Yatasto no le gusta ningún jockey

También sabemos el Stud o la caballeriza al que representa cada jockey
Valdivieso y Falero son del stud El Tute
Lezcano representa a Las Hormigas
Y Baratucci y Leguisamo a El Charabón

Por otra parte, sabemos que Botafogo ganó el Gran Premio Nacional y el Gran Premio República, Old Man ganó el Gran Premio República y el Campeonato Palermo de Oro y 
Enérgica y Yatasto no ganaron ningún campeonato. Mat Boy ganó el Gran Premio Criadores.

Modelar estos hechos en la base de conocimientos e indicar en caso de ser necesario si algún concepto interviene a la hora de hacer dicho diseño justificando su decisión.
*/

% lesJockeys(NombreDeLaPersona,Altura,Peso)
lesJockeys(valdivieso,155,52).
lesJockeys(leguisamo,161,49).
lesJockeys(lezcano,149,50).
lesJockeys(baratucci,153,55).
lesJockeys(falero,157,52).

% representa(NombreDeLaPersona,Stud)
representa(valdivieso,eltute).
representa(falero,eltute).
representa(lezcano,lasHormigas).
representa(baratucci,elcharabon).
representa(leguisamo,elcharabon).

% caballos (NombreDelCaballo)
caballos(botafogo).
caballos(oldMan).
caballos(energica).
caballos(matBoy).
caballos(yatasto).

% gano(NombreDelCaballo,Premio)
gano(botafogo,granPremioNacional).
gano(botafogo,granPremioRepublica).
gano(oldMan,granPremioRepublica).
gano(oldMan,campeonatoPalermoDeOro).
gano(matBoy,granPremioCriadores).

prefiere(botafogo,baratucci).

prefiere(botafogo,Nombre):-
    lesJockeys(Nombre,_,Peso),
    Peso < 52.

prefiere(oldMan,Nombre):-
    lesJockeys(Nombre,_,_),
    atom_length(Nombre,CantidadDeLetras),
    CantidadDeLetras > 7.

prefiere(energica,Nombre):-
    lesJockeys(Nombre,_,_),
    not(prefiere(botafogo,Nombre)).

prefiere(matBoy,Nombre):-
    lesJockeys(Nombre,Altura,_),
    Altura > 170.

/* Punto 2: Para mí, para vos (2 puntos)
Queremos saber quiénes son los caballos que prefieren a más de un jockey. Ej: Botafogo, Old Man y Enérgica son caballos 
que cumplen esta condición según la base de conocimiento planteada. El predicado debe ser inversible.
*/

%2 Soluciones equivalentes

prefiereAMasDeUnJockey(Caballo):-
    prefiere(Caballo,Nombre),
    prefiere(Caballo,NombreDos),
    Nombre \= NombreDos.

prefiereAMasDeUnJockey(Caballo):-
    caballos(Caballo),
    findall(Nombre,prefiere(Caballo,Nombre),ListaDeQueridos),
    length(ListaDeQueridos, Cantidad), 
    Cantidad > 1.
    
/* Punto 3: No se llama Amor (2 puntos)
Queremos saber quiénes son los caballos que no prefieren a ningún jockey de una caballeriza. El predicado debe ser inversible. 
Ej: Botafogo aborrece a El Tute (porque no prefiere a Valdivieso ni a Falero), Old Man aborrece a Las Hormigas y Mat Boy aborrece a todos los studs, entre otros ejemplos.
*/

aborrece(Caballo,Stud):-
    representa(_, Stud),
    caballos(Caballo),
    forall(representa(Nombre,Stud),not(prefiere(Caballo,Nombre))).

/*Punto 4: Piolines (2 puntos)
Queremos saber quiénes son les jockeys "piolines", que son las personas preferidas por todos los caballos que ganaron un premio importante. 
El Gran Premio Nacional y el Gran Premio República son premios importantes.
Por ejemplo, Leguisamo y Baratucci son piolines, no así Lezcano que es preferida por Botafogo pero no por Old Man. El predicado debe ser inversible.
*/

sonPiolines(Nombre):-
    lesJockeys(Nombre,_,_),
    forall(ganoPremioImportante(Caballo),prefiere(Caballo,Nombre)).

ganoPremioImportante(Caballo):-
    gano(Caballo,Premio),
    premioImportante(Premio).

premioImportante(granPremioNacional).
premioImportante(granPremioRepublica).


% Punto 5: El jugador
% Apuestas (2 puntos)
% Queremos registrar las apuestas que hacen ciertas personas, una persona puede apostar 
% a ganador por un caballo => gana si el caballo resulta ganador
% a segundo por un caballo => gana si el caballo sale primero o segundo
% exacta => apuesta por dos caballos, y gana si el primer caballo sale primero y el segundo caballo sale segundo
% imperfecta => apuesta por dos caballos y gana si los caballos terminan primero y segundo sin importar el orden
% Queremos saber, dada una apuesta y el resultado de una carrera de caballos si la apuesta resultó ganadora.
% El predicado no debe ser inversible.
ganadora(ganador(Caballo), Resultado):-salioPrimero(Caballo, Resultado).
ganadora(segundo(Caballo), Resultado):-salioPrimero(Caballo, Resultado).
ganadora(segundo(Caballo), Resultado):-salioSegundo(Caballo, Resultado).
ganadora(exacta(Caballo1, Caballo2),Resultado):-salioPrimero(Caballo1, Resultado), salioSegundo(Caballo2, Resultado).
ganadora(imperfecta(Caballo1, Caballo2),Resultado):-salioPrimero(Caballo1, Resultado), salioSegundo(Caballo2, Resultado).
ganadora(imperfecta(Caballo1, Caballo2),Resultado):-salioPrimero(Caballo2, Resultado), salioSegundo(Caballo1, Resultado).

salioPrimero(Caballo, [Caballo|_]).
salioSegundo(Caballo, [_|[Caballo|_]]).

% Punto 6: Los colores
% Sabiendo que cada caballo tiene un color de crin:
% - Botafogo es tordo (negro)
% - Old Man es alazán (marrón)
% - Enérgica es ratonero (gris y negro) 
% - Mat Boy es palomino (marrón y blanco)
% - Yatasto es pinto (blanco y marrón)
% queremos saber qué caballos podría comprar una persona que tiene preferencia
% por caballos de un color específico. Tiene que poder comprar por lo menos un caballo para que
% la solución sea válida.
%
% Esperamos que no haya una única solución, sino que se pueda conocer todas las alternativas válidas posibles.
crin(botafogo, tordo).
crin(oldMan, alazan).
crin(energica, ratonero).
crin(matBoy, palomino).
crin(yatasto, pinto).

color(tordo, negro).
color(alazan, marron).
color(ratonero, gris).
color(ratonero, negro).
color(palomino, marron).
color(palomino, blanco).
color(pinto, blanco).
color(pinto, marron).

comprar(Color, Caballos):-
  findall(Caballo, (crin(Caballo, Crin), color(Crin, Color)), CaballosPosibles),
  combinar(CaballosPosibles, Caballos),
  Caballos \= [].

combinar([], []).
combinar([Caballo|CaballosPosibles], [Caballo|Caballos]):-combinar(CaballosPosibles, Caballos).
combinar([_|CaballosPosibles], Caballos):-combinar(CaballosPosibles, Caballos).
