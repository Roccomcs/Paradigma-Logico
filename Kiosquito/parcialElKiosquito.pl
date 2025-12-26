/*
... Consigna y base de conocimientos del Kiosquito ...
*/

% atiende(Persona,Dia,HoraInicio,HoraFinal).
atiende(dodain,lunes,9,15).
atiende(dodain,miercoles,9,15).
atiende(dodain,viernes,9,15).
atiende(lucas,martes,10,20).
atiende(juanC,sabado,18,22).
atiende(juanC,domingo,18,22).
atiende(juanFdS,jueves,10,20).
atiende(juanFdS,viernes,12,20).
atiende(leoC,lunes,14,18).
atiende(leoC,miercoles,14,18).
atiende(martu,miercoles,23,24).

% atiendeMismoDia(Persona,OtraPersona).
atiende(vale,Dia,HoraInicio,HoraFin):-
    atiende(dodain,Dia,HoraInicio,HoraFin).

atiende(vale,Dia,HoraInicio,HoraFin):-
    atiende(juanC,Dia,HoraInicio,HoraFin).

% piensaAtender(Persona,Dia,HoraInicio,HoraFinal).
piensaAtender(maiu,martes,0,8).
piensaAtender(maiu,miercoles,0,8).

quienAtiende(Dia,Hora,Persona):-
    atiende(Persona,Dia,HoraInicio,HoraFin),
    between(HoraInicio, HoraFin, Hora).

atiendeSola(Persona,Dia,Hora):-
    atiende(Persona,_,_,_),
    findall(Persona, quienAtiende(Dia,Hora,Persona), ListaDePersonas),
    length(ListaDePersonas, Cantidad),
    Cantidad is 1.

atiendeSola(Persona,Dia,Hora):-
    quienAtiende(Dia,Hora,Persona),
    not((quienAtiende(Dia,Hora,OtraPersona), Persona \= OtraPersona)).  

posibilidadesAtencion(Dia, Personas):-
  findall(Persona, quienAtiende(Dia,_,Persona), PersonasPosibles),
  combinar(PersonasPosibles, Personas).

combinar([], []).
combinar([Persona|PersonasPosibles], [Persona|Personas]):-combinar(PersonasPosibles, Personas).
combinar([_|PersonasPosibles], Personas):-combinar(PersonasPosibles, Personas).

ventas(dodain,10,8,[golosinas(1200),cigarrillos([jockey]),golosinas(50)]).
ventas(dodain,12,8,[bebida(si,8),bebida(no,1),golosinas(10)]).
ventas(martu,12,8,[golosinas(1000),cigarrillos([chesterfield,colorado,parisiennes])]).
ventas(lucas,11,8,[golosinas(600)]).
ventas(lucas,18,8,[bebida(no,2),cigarrillos([derby])]).

esSuertuda(Persona):-
    ventas(Persona,_,_,_),
    forall(ventas(Persona,_,_,[PrimeraVenta|_]), esVentaImportante(PrimeraVenta)).

esVentaImportante(golosinas(Valor)):- Valor > 100.

esVentaImportante(cigarrillos(ListaDeMarcas)):-
    length(ListaDeMarcas,Cantidad),
    Cantidad > 2.

esVentaImportante(bebida(si,_)).
esVentaImportante(bebida(_,Cantidad)):- Cantidad > 5.
