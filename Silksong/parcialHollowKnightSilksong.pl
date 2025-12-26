:- dynamic ends_with/2.

words(Text, Words):-
    ( atom(Text) -> atom_string(Text, S) ; S = Text ),
    split_string(S, " ", " \t\n.,;:!()\"'", Words).

% words y ends_with por enunciado

% GPT
fecha_num(date(Y,M,D), N):- N is Y*10000 + M*100 + D.

fechaAntes(F1,F2):-
    fecha_num(F1,N1), fecha_num(F2,N2), N1 < N2.

fechaDespues(F1,F2):-
    fecha_num(F1,N1), fecha_num(F2,N2), N1 > N2.

% 1) Modelar la base de conocimientos inicial
%   Representar usuarios, tweets (con id, autor, fecha y contenido), likes, dislikes, retweets,

% caracteristicasUsuario(Usuario,Seguidores,Seguidos,TipoDeCuenta).
caracteristicasUsuario(elfedi, 120, 45, normal).
caracteristicasUsuario(maiiiii, 200, 30, administrador).
caracteristicasUsuario(luchitocabj, 15, 10, normal).
caracteristicasUsuario(xXx_JOacO_xXx, 5, 3, normal).
caracteristicasUsuario(mili, 50, 12, normal).
caracteristicasUsuario(cami_lazzati, 80, 40, normal).
caracteristicasUsuario(catalapridaa, 60, 20, normal).

% tweet(Usuario,Contenido,Fecha,Id).
tweet(elfedi, "Viva Perón, carajo!!", date(2011,12,10), t1).
tweet(maiiiii, "Prolog?", date(2025,11,27), t2).
tweet(luchitocabj, "CABANI TE CRUSO Y SOS POYO", date(2023,11,4), t3).
tweet(cami_lazzati, "quien para un lol?", date(2025,11,27), t15).

% sigueA(Usuario,OtroUsuario).
sigueA(catalapridaa, cami_lazzati).

% retwitteo(Usuario,Id).
retwitteo(luchitocabj, t15).

% leDioLike(Usuario,Id).
leDioLike(xXx_JOacO_xXx, t3).

% leDioDislike(Usuario,Id).
leDioDislike(maiiiii, t1).

% 2) tweetValido/1 es verdadero si el contenido del tweet con id `Id` tiene <= 140 caracteres.
tweetValido(Id):-
    tweet(_,Contenido,_,Id),
    cantidadDeCaracteres(Contenido,Cantidad),
    Cantidad < 141.

cantidadDeCaracteres(Contenido,Cantidad):-
    string_length(Contenido,Cantidad).

% ratio/2 donde Diferencia = (likes) - (dislikes) que haya recibido el tweet Id.

ratio(Id,Diferencia):-
    tweet(_,_,_,Id),
    cantidadDeLikes(Id,CantidadDeLikes),
    cantidadDeDislikes(Id,CantidadDeDislikes),
    Diferencia is CantidadDeLikes - CantidadDeDislikes.

cantidadDeLikes(Id,CantidadDeLikes):-
    findall(Usuario, leDioLike(Usuario,Id), ListaDeLikes),
    length(ListaDeLikes,CantidadDeLikes).

cantidadDeDislikes(Id,CantidadDeDislikes):-
    findall(Usuario, leDioDislike(Usuario,Id), ListaDeDislikes),
    length(ListaDeDislikes,CantidadDeDislikes).

% esTroll/1 Un usuario es troll si cumple alguna de las dos condiciones:
%     a) "solo postea ragebait": el usuario es `premium` y todas sus publicaciones son preguntas (terminan en '?').
%     b) "solo postea hechos": el usuario no es `administrador` y todos sus tweets son inválidos (`tweetValido/1` falso) y además tienen ratio negativo.

esTroll(Usuario):-
    tweet(Usuario,_,_,_),
    forall(tweet(Usuario,_,_,Id),ragebaitOFacto(Usuario,Id)).

ragebaitOFacto(Usuario, Id) :- facto(Usuario, Id).
ragebaitOFacto(Usuario, Id) :- ragebait(Usuario, Id). 

facto(Usuario,Id):-
    not(caracteristicasUsuario(Usuario,_,_,administrador)),
    not(tweetValido(Id)),
    ratio(Id,Diferencia), 
    Diferencia < 0.

ragebait(Usuario,Id):-
    caracteristicasUsuario(Usuario,_,_,premium),
    tweet(Usuario,Contenido,_,Id),
    esTweetPregunta(Contenido).

esTweetPregunta(Contenido):-
    ends_with("?",Contenido).

% estanEntongados/2 -> verdadero si U1 y U2 son trolls, se siguen mutuamente y cada uno le dio like a todos los tweets del otro.
 
estanEntongados(Usuario,OtroUsuario):-
    Usuario \= OtroUsuario,
    tweet(Usuario,_,_,_),
    tweet(OtroUsuario,_,_,_),
    sonTrolls(Usuario,OtroUsuario),
    seSiguenYLikean(Usuario,OtroUsuario),
    seSiguenYLikean(OtroUsuario,Usuario).


sonTrolls(Usuario,OtroUsuario):-
    esTroll(Usuario),
    esTroll(OtroUsuario).

seSiguenYLikean(Usuario,OtroUsuario):-
    sigueA(Usuario,OtroUsuario),
    forall(tweet(Usuario,_,_,Id), leDioLike(OtroUsuario,Id)).

% grokEstoEsPosta/2 -> clasifica el Contenido (o trabajar por Id usando tweet/4): si el autor es troll -> ficticio.
%   Si no es troll: descomponer el contenido en palabras, para cada palabra obtener gradoDeCerteza/2, promediar (sum_list + length) y clasificar según umbrales (>=9 real, 4..8 dudoso, <4 ficticio).
gradoDeCerteza(Palabra,Promedio).  % Ya implementado por enunciado

gradoDeCertezaDelTexto(Contenido,PromedioFinal):-
    words(Contenido,ListaDePalabras),
    findall(Valor,(member(Palabra,ListaDePalabras),gradoDeCerteza(Palabra,Valor)),ValorTotal),
    sum_list(ValorTotal, Suma),
    length(ValorTotal,Cantidad),
    PromedioFinal is Suma / Cantidad.
    
grokEstoEsPosta(Contenido,real):-
    tweet(Usuario,Contenido,_,_),
    not(esTroll(Usuario)),
    gradoDeCertezaDelTexto(Contenido,PromedioFinal),
    PromedioFinal > 8.

grokEstoEsPosta(Contenido,dudoso):-
    tweet(Usuario,Contenido,_,_),
    not(esTroll(Usuario)),
    gradoDeCertezaDelTexto(Contenido,PromedioFinal),
    PromedioFinal < 9,
    PromedioFinal > 3.

grokEstoEsPosta(Contenido,ficticio):-
    tweet(Usuario,Contenido,_,_),
    esTroll(Usuario).

grokEstoEsPosta(Contenido,ficticio):-
    tweet(_,Contenido,_,_),
    gradoDeCertezaDelTexto(Contenido,PromedioFinal),
    PromedioFinal < 4.

% resultadoDeBusqueda/3 -> devuelve la lista de Ids (tweets que el usuario escribió o retwitteó) que cumplen la `Condicion`.
%   Condiciones posibles (modelar como términos): antesDe(Fecha), despuesDe(Fecha), conRatioNegativo, combinada(C1,C2) aplicando ambas, y cualquier otra que desees.
resultadoDeBusqueda(Usuario,Condicion,ListaDeIds):-
    tweet(Usuario,_,_,_),
    findall( Id, (tweet(Usuario,_,_,Id), cumpleCondicion(Condicion,Id)),ListaDeIds).   

cumpleCondicion(anterior(Fecha),Id):-
    tweet(_,_,FechaTweet,Id),
    fechaAntes(FechaTweet,Fecha).
    
cumpleCondicion(despues(Fecha),Id):-
    tweet(_,_,FechaTweet,Id),
    fechaDespues(FechaTweet,Fecha).

cumpleCondicion(ratioNegativo,Id):-
    ratio(Id,Diferencia),
    Diferencia < 0.

cumpleCondicion(combinada(Condicion1, Condicion2),Id):-
    cumpleCondicion(Condicion1,Id),
    cumpleCondicion(Condicion2,Id).


