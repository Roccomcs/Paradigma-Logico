% integrante(Grupo,Nombre,Instrumento).
integrante(sophieTrio, sophie, violin).
integrante(sophieTrio, santi, guitarra).
integrante(vientosDelEste, lisa, saxo).
integrante(vientosDelEste, santi, voz).
integrante(vientosDelEste, santi, guitarra).
integrante(jazzmin, santi, bateria).

% nivelQueTiene(Nombre,Instrumento,Improvisacion).
nivelQueTiene(sophie, violin, 5).
nivelQueTiene(santi, guitarra, 2).
nivelQueTiene(santi, voz, 3).
nivelQueTiene(santi, bateria, 4).
nivelQueTiene(lisa, saxo, 4).
nivelQueTiene(lore, violin, 4).
nivelQueTiene(luis, trompeta, 1).
nivelQueTiene(luis, contrabajo, 4).
nivelQueTiene(ana, piano, 0).
nivelQueTiene(rocco, contrabajo, 0).
nivelQueTiene(luca, bateria, 0).
nivelQueTiene(tomas, violin, 0).

%instrumento(Instrumento,Rol).
instrumento(violin, melodico(cuerdas)).
instrumento(guitarra, armonico).
instrumento(bateria, ritmico).
instrumento(saxo, melodico(viento)).
instrumento(trompeta, melodico(viento)).
instrumento(contrabajo, armonico).
instrumento(bajo, armonico).
instrumento(piano, armonico).
instrumento(pandereta, ritmico).
instrumento(voz, melodico(vocal)).

/*
Saber si un grupo tiene una buena base, que sucede si hay algún integrante de ese grupo 
que toque un instrumento rítmico y alguien más que toque un instrumento armónico.
*/

tieneBuenaBase(Grupo):-
    integrante(Grupo,Nombre,Instrumento),
    integrante(Grupo,OtroNombre,OtroInstrumento),
    instrumento(Instrumento,ritmico),
    instrumento(OtroInstrumento,armonico),
    Nombre \= OtroNombre.

%Abstraccion de logica
tieneBuenaBase(Grupo):-
    tocaInstrumentoTipo(Grupo,Nombre,ritmico),
    tocaInstrumentoTipo(Grupo,OtroNombre,armonico),
    Nombre \= OtroNombre.

tocaInstrumentoTipo(Grupo,Nombre,Rol):-
    integrante(Grupo,Nombre,Instrumento),
    instrumento(Instrumento,Rol).

/*
Saber si una persona se destaca en un grupo, que se cumple si el nivel con el que toca 
un instrumento en el grupo en cuestión es al menos dos puntos más del nivel con el que 
tocan sus instrumentos todos los demás integrantes.Con los datos actuales, sophie se 
destacaría en sophieTrio y nadie en vientosDelEste.
*/

seDestaca(Nombre,Grupo):-
    nivelDeImprovisacion(Nombre,Grupo,Improvisacion),
    forall((nivelDeImprovisacion(OtroNombre,Grupo,OtraImprovisacion), OtroNombre \= Nombre), Improvisacion - 2 > OtraImprovisacion).

nivelDeImprovisacion(Nombre,Grupo,Improvisacion):-
    integrante(Grupo,Nombre,Instrumento),
    nivelQueTiene(Nombre,Instrumento,Improvisacion).

/*
Incorporar a la base de conocimientos la información sobre los distintos grupos que se 
están armando mediante un predicado grupo/2 que relacione a un grupo con el tipo de grupo 
en cuestión. En principio cada grupo puede ser una big band o requerir una formación 
particular (para las cuales se indicará a su vez cuáles son los instrumentos que requiere para estar completo).
El grupo vientosDelEste es una big band.
El grupo sophieTrio tiene una formación de contrabajo, guitarra y violín.
El grupo jazzmin también tiene una formación particular, en este caso de batería, bajo, trompeta, piano y guitarra.
Sabemos que habrán otros tipos de grupos a considerar más adelante, por lo que la solución 
propuesta para los requerimientos posteriores debería poder extenderse fácilmente en estos términos.
*/

% grupos(Grupo,TipoDeGrupo).
grupos(vientosDelEste,bigBand).
grupos(sophieTrio,formacion([contrabajo,guitarra,violin])).
grupos(jazzmin,formacion([bateria,bajo,trompeta,piano,guitarra])).

% Punto 8
grupos(estudio1,ensamble(3)).

/*
Saber si hay cupo para un instrumento en un grupo.
En particular, para los grupos de tipo big band siempre hay cupo para los instrumentos melódicos de viento.
Por otro lado, independientemente del tipo de grupo del que se trate, normalmente se cumple que hay cupo 
para un instrumento si no hay alguien que ya toque ese mismo instrumento en el grupo, y además el instrumento 
sirve para el tipo de grupo en cuestión.

Respecto a qué instrumentos sirven:
si se trata de una formación particular, sirve si es un instrumento de los que se buscaban para esa formación,
para las big bands, además de los instrumentos de viento, sirven la batería, el bajo y el piano.
*/

hayCupo(Instrumento,Grupo):-
    instrumento(Instrumento,_),
    grupos(Grupo,TipoDeGrupo),
    sirveInstrumento(Instrumento,TipoDeGrupo),
    not(integrante(Grupo,_,Instrumento)).

sirveInstrumento(Instrumento,formacion(Instrumentos)):-
    member(Instrumento,Instrumentos).

sirveInstrumento(Instrumento,bigBand):-
    esDeViento(Instrumento).
sirveInstrumento(bateria,bigBand).
sirveInstrumento(bajo,bigBand).
sirveInstrumento(piano,bigBand).

esDeViento(Instrumento):-
    instrumento(Instrumento,melodico(viento)).

%Punto 8
sirveInstrumento(ensamble(_), _).

/*
Saber si una persona puede incorporarse a un grupo y con qué instrumento, que se verifique si la persona 
no forma parte ya de dicho grupo, además hay cupo para ese instrumento y el nivel que tiene la persona 
con ese instrumento es mayor o igual al mínimo esperado para el grupo.
Si se trata de una big band el nivel mínimo es 1, y si se trata de una formación particular 
será 7 - la cantidad de instrumentos buscados para esa formación.
*/

puedeIncorporarse(Nombre,Grupo,Instrumento):-
    grupos(Grupo,TipoDeGrupo),
    noFormaParteDelGrupo(Nombre,Grupo),
    hayCupo(Instrumento,Grupo),
    tieneNivelEsperado(Nombre,Instrumento,TipoDeGrupo).

noFormaParteDelGrupo(Nombre,Grupo):-
    not(integrante(Grupo,Nombre,_)).

tieneNivelEsperado(Nombre,Instrumento,TipoDeGrupo):-
    nivelQueTiene(Nombre,Instrumento,Improvisacion),
    nivelMinimo(TipoDeGrupo, NivelMinimo),
    Improvisacion >= NivelMinimo.

nivelMinimo(bigBand,1).

nivelMinimo(formacion(Instrumentos),NivelMinimo):-
    length(Instrumentos, Cantidad),
    NivelMinimo is 7 - Cantidad.

%Punto 8
nivelMinimo(ensamble(NivelMinimo), NivelMinimo).

/*
Saber si una persona se quedó en banda, que se cumple si no forma 
parte de un grupo y no hay ningún grupo al que pueda incorporarse.
*/

seQuedoEnBanda(Persona):-
    nivelQueTiene(Persona, _,_),
    not(integrante(_, Persona, _)),
    not(puedeIncorporarse(Persona, _, _)).

/*
Saber si un grupo puede tocar, que se cumple si con los integrantes que tocan algún 
instrumento en ese grupo logran cubrir las necesidades mínimas que tienen, considerando que...
Si se trata de una big band hace falta tener una buena base 
y por lo menos 5 personas que toquen instrumentos de viento.
Si es una formación particular, debería cumplirse que para 
todos los instrumentos requeridos tienen alguien en el grupo que lo toque.
*/

puedeTocar(Grupo):-
    grupos(Grupo,TipoDeGrupo),
    cumplenNecesidadesMinimas(Grupo,TipoDeGrupo).

cumplenNecesidadesMinimas(Grupo,bigBand):-
    tieneBuenaBase(Grupo),
    instrumentosDeViento(Grupo,Cantidad),
    Cantidad >= 5.

instrumentosDeViento(Grupo,Cantidad):-
    findall(Nombre,(integrante(Grupo, Nombre, Instrumento),instrumento(Instrumento,melodico(viento))),PersonasQueTocanViento),
    length(PersonasQueTocanViento, Cantidad).
    
cumplenNecesidadesMinimas(Grupo,formacion(Instrumentos)):-
    forall(member(Instrumento,Instrumentos), integrante(Grupo,_,Instrumento)).
    
/*
Finalmente queremos incorporar a nuestra base de conocimientos grupos de otro tipo de los que ya tenemos: los ensambles.
Para cada ensamble deberá informarse cuál es el nivel mínimo que tiene que tener una 
persona con su instrumento para poder incorporarse al grupo correspondiente.
Además sabemos que para los ensambles cualquier instrumento sirve, y para que puedan tocar hace falta una buena 
base y al menos alguna persona que toque un instrumento melódico sin importar de qué tipo.
Agregar a la base de conocimientos al grupo estudio1 que es un ensamble que requiere tener 
un nivel con el instrumento de al menos 3 para poder incorporarse, y adaptar la lógica desarrollada 
en los puntos anteriores para que funcionen correctamente con los ensambles.
*/

puedeTocar(Grupo):-
    grupos(Grupo, ensamble(_)),
    tieneBuenaBase(Grupo),
    tocaInstrumentoTipo(Grupo,_,melodico(_)).
