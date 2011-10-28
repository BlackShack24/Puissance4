max(X,Y,Y) :- Y>X, !.
max(X,Y,X). 

ajoutFin(X,[],[X]).
ajoutFin(X,[Y|L1],[Y|L2]):- ajoutFin(X,L1,L2).

% Fonction qui renvoie une sous-liste � partir d'une liste L
% description...
/* Param�tres : S sous-liste, L liste */
prefix(P,L):-append(P,_,L).
sublist(S,L):-prefix(S,L).
sublist(S,[_|T]):-sublist(S,T).

% Fonction qui retourne la longueur d'une liste
/* Param�tres : L liste, N longueur de la liste */
longueur([],0).
longueur([_|L],N):- longueur(L,N1),
					 N is N1+1.

% Fonction qui renvoie le ni�me �l�ment d'une liste 
/* Param�tres : N index de l'�lement qu'on veut r�cup�rer, L liste, X �l�ment retourn� */
nthElem(N, L, []):- longueur(L, N1), N1 < N.
nthElem(N, L, X):- nth1(N, L, X).				

% Fonction qui enregistre un coup jou� dans la grille
/* Param�tres : N num�ro de la colonne dans laquelle J joue, G grille, J joueur, G' nouvelle grille */		
enregistrerCoup(1, [L|G], a, _, I):- longueur(L,N), N >= 6, write('Coup Invalide\n'), jouerCoupA(I).
enregistrerCoup(1, [L|G], b, _, I):- longueur(L,N), N >= 6, write('Coup Invalide\n'), jouerCoupB(I).
enregistrerCoup(1, [L|G], J, F, I):- longueur(L,N), N < 6, ajoutFin(J,L,M), F=[M|G].
enregistrerCoup(N, [T|X], J, [T|G], I):- 	N > 0,
										N1 is N-1,
										enregistrerCoup(N1, X, J, G, I).

enregistrerCoupJoueur(1, [L|G], a, _, I):- longueur(L,N), N >= 6, write('Coup Invalide\n'), jouerCoupJoueur(I).
enregistrerCoupJoueur(1, [L|G], J, F, I):- longueur(L,N), N < 6, ajoutFin(J,L,M), F=[M|G].
enregistrerCoupJoueur(N, [T|X], J, [T|G], I):- 	N > 0,
										N1 is N-1,
										enregistrerCoupJoueur(N1, X, J, G, I).

enregistrerCoupIA(1, [L|G], J, F, I):- longueur(L,N), N < 6, ajoutFin(J,L,M), F=[M|G].
enregistrerCoupIA(N, [T|X], J, [T|G], I):- 	N > 0,
										N1 is N-1,
										enregistrerCoupIA(N1, X, J, G, I).
% Condition de victoire verticale : 4 jetons les uns apr�s les autres sur une m�me colonne
/* Param�tres : G grille, J joueur */										
finJeuVert([L|_],J):- sublist([J,J,J,J], L),!.
finJeuVert([_|G],J):- finJeuVert(G,J).

% Condition de victoire horizontale : 4 jetons les uns apr�s les autres sur une m�me ligne
/* Param�tres : N num�ro de la ligne � partir duquel on traite, G grille, J joueur */
finJeuHor(N, G, J):- maplist(nthElem(N), G, L), 
					 sublist([J,J,J,J],L),!.
finJeuHor(N, G, J):- N > 0,
					 N1 is N-1,
					 finJeuHor(N1, G, J).

finJeuHor(G,J):- finJeuHor(6, G, J).				 

uneFinDiag(G,D,J,0):- sublist([J,J,J,J],D).
uneFinDiag(G,D,J,N):- N > 0,
					  maplist(nthElem(N), G, L),
					  nthElem(N,L,E),
					  N1 is N-1,
					  uneFinDiag(G,[E|D],J,N1).

uneFinDiag(G,J):- uneFinDiag(G,[],J,6).

autreFinDiag(G,D,J,0):- sublist([J,J,J,J],D).
autreFinDiag(G,D,J,N):- N > 0,
					    maplist(nthElem(N), G, L),
						N2 is 7-N,
						nthElem(N2,L,E),
					    N1 is N-1,
					    autreFinDiag(G,[E|D],J,N1).

autreFinDiag(G,J):- autreFinDiag(G,[],J,6).


finJeuDiag(G,N,X,J):- autreFinDiag(X,J),!.
finJeuDiag(G,N,X,J):- uneFinDiag(X,J),!.
finJeuDiag(G,N,X,J):- N < 7,
					  maplist(nthElem(N), G, L),
					  N1 is N+1,
					  finJeuDiag(G,N1,[L|X],J).

finJeuDiag(G,J):- finJeuDiag(G,1,[],J).

% D�finition et test des conditions de fin de jeu
/* Param�tres : G grille, J joueur */
finJeu(G, J):- finJeuVert(G,a), J=a.
finJeu(G, J):- finJeuVert(G,b), J=b.
finJeu(G, J):- finJeuHor(G,a), J=a.
finJeu(G, J):- finJeuHor(G,b), J=b.
finJeu(G, J):- finJeuDiag(G,a), J=a.
finJeu(G, J):- finJeuDiag(G,b), J=b.

% Affichage du gagnant
/* Param�tres : J joueur */
gagnant(J):-write('Le Joueur '), write(J), write(' a gagn� !').


/* Param�tres : G grille*/
jouerCoupA(G):-finJeu(G,J), gagnant(J),!.
jouerCoupB(G):-finJeu(G,J), gagnant(J),!.
jouerCoupA(G):- write('Joueur A, entrez un num�ro de colonne : '),
				read(N), enregistrerCoup(N,G, a, X, G),
				afficherGrille(X),
				write('\n'),
				jouerCoupB(X).
jouerCoupB(G):- write('Joueur B, entrez un num�ro de colonne : '),
				read(N), enregistrerCoup(N,G, b, X, G),
				afficherGrille(X),
				write('\n'),
				jouerCoupA(X).

% Lancement du jeu : grille de d�part de 6*7 (vide). C'est le joueur 'a' qui commence, suivi par b, jusqu'� ce que l'un des deux gagne [ou GRILLE PLEINE]
jouer:- jouerCoupA([[],[],[],[],[],[],[]]).

%Un coup gagant est un coup qui mene � un �tat de jeu ou le joueur est vainqueur
coupGagnant(C,G,J):- enregistrerCoupIA(1,G,J,N,G), finJeu(N,J), C=1.
coupGagnant(C,G,J):- enregistrerCoupIA(2,G,J,N,G), finJeu(N,J), C=2.
coupGagnant(C,G,J):- enregistrerCoupIA(3,G,J,N,G), finJeu(N,J), C=3.
coupGagnant(C,G,J):- enregistrerCoupIA(4,G,J,N,G), finJeu(N,J), C=4.
coupGagnant(C,G,J):- enregistrerCoupIA(5,G,J,N,G), finJeu(N,J), C=5.
coupGagnant(C,G,J):- enregistrerCoupIA(6,G,J,N,G), finJeu(N,J), C=6.
coupGagnant(C,G,J):- enregistrerCoupIA(7,G,J,N,G), finJeu(N,J), C=7.

jouerCoupJoueur(G):-finJeu(G,J), gagnant(J),!.
jouerIA(G):-finJeu(G,J), gagnant(J),!.

%Si un coup permet de gagner il faut le jouer.
jouerIA(G):-   coupGagnant(C,G,b), enregistrerCoupIA(C,G,b,X,G),
			   afficherGrille(X),
			   write('\n'),
			   jouerCoupJoueur(X).

%Si un coup permet a l'adversaire de jouer on se d�fend.
jouerIA(G):-   coupGagnant(C,G,a), enregistrerCoupIA(C,G,b,X,G),
			   afficherGrille(X),
			   write('\n'),
			   jouerCoupJoueur(X).

jouerIA(0, G):- write('Pas de coup trouv�').


jouerIA(C, G):- enregistrerCoupIA(C,G,b,X,G),
			    afficherGrille(X),
			    write('\n'),
			    jouerCoupJoueur(X).

%Si on a pas de coup imm�diat on fait un coup au centre ou au plus pr�s possible.
jouerIA(G):- jouerIA(4,G).
jouerIA(G):- jouerIA(5,G).
jouerIA(G):- jouerIA(3,G).
jouerIA(G):- jouerIA(6,G).
jouerIA(G):- jouerIA(2,G).
jouerIA(G):- jouerIA(7,G).
jouerIA(G):- jouerIA(1,G).
jouerIA(G):- jouerIA(0,G).

jouerCoupJoueur(G):- write('Joueur A, entrez un num�ro de colonne : '),
				read(N), enregistrerCoupJoueur(N,G, a, X, G),
				afficherGrille(X),
				write('\n'),
				jouerIA(X).

lancerIA:- jouerIA([[],[],[],[],[],[],[]]).

enregistrerCoupArbre(1, [L|G], J, [[J|L]|G]):- longueur(L,N), N < 6.
enregistrerCoupArbre(N, [T|X], J, [T|G]):- 	N > 0,
										N1 is N-1,
										enregistrerCoupArbre(N1, X, J, G).
% Evaluation de la grille de jeu
/* Param�tres : G grille, J joueur */
evalVert([], _, P, X):- X=P, write(fini).										
evalVert([L|G],J, P, X):- 	sublist([J,J,J,J], L),
							evalVert(G, J, P, 4, X).
evalVert([L|G],J, P, X):- 	sublist([J,J,J], L),
							evalVert(G, J, P, 3, X).
evalVert([L|G],J, P, X):- 	sublist([J,J], L),
							evalVert(G, J, P, 2, X).
evalVert([L|G],J, P, X):- evalVert(G, J, P, 1, X).
evalVert(G,J, P1, P2, X):- 	max(P1, P2, P),
							evalVert(G, J, P, X).
evalVert(G, J, X):- evalVert(G,J, 0, 1, X).

/* Param�tres : N num�ro de la ligne � partir duquel on traite, G grille, J joueur */
evalHor(_,[],J,P):- write(fini).
evalHor(N, G, J, P):- maplist(nthElem(N), G, L), 
					 sublist([J,J,J,J],L),
					 evalHor(N, G, J, P, 4).
evalHor(N, G, J, P):- maplist(nthElem(N), G, L), 
					 sublist([J,J,J],L),
					 evalHor(N, G, J, P, 3).
evalHor(N, G, J, P):- maplist(nthElem(N), G, L), 
					 sublist([J,J],L),
					 evalHor(N, G, J, P, 2).
evalHor(N, G, J, P):- maplist(nthElem(N), G, L), 
					 sublist([J],L),
					 evalHor(N, G, J, P, 1).
evalHor(N, G, J, P1, P2):- N > 0,
					 N1 is N-1,
					 write(toto),
					 max(P1, P2, P),
					 evalHor(N1, G, J, P),
					 write(P).
evalHor(G,J,P):- evalHor(6, G, J, 0, 1).

evalGrille(G, J, X) :- evalHor(G,J,P1),
					evalVert(G, J, P2),	
					max(P1,P2, X).								
										
/* Param�tres : G grille, J joueur, P profondeur, A arbre obtenu */
tracerArbre(G, J, 0, A).
tracerArbre(G, J, P, A):- P > 0,
					      P1 is P-1,
						  tracerBranche(G, J, P1, A, 7).

tracerBranche(G, J, P, A, 1).						  
tracerBranche(G, a, P, A, N):- N > 0,
							   N1 is N-1,
							   enregistrerCoupArbre(N, G, a, X), 
							   tracerArbre(X, b, P, A),
							   tracerBranche(G, a, P, A, N1).			
tracerBranche(G, b, P, A, N):- N > 0,
							   N1 is N-1,
							   enregistrerCoupArbre(N, G, b, X), 
							   tracerArbre(X, a, P, A),
							   tracerBranche(G, b, P, A, N1).
afficherGrille(_,0).							   
afficherGrille(G, N):-	 N > 0,
						N1 is N-1,
						maplist(nthElem(N), G, L),
						afficherListe(L),
						write('\n'),
						afficherGrille(G, N1).

afficherGrille(G):- afficherGrille(G,6).
 
afficherListe([]):- write('|').
afficherListe([E|L]):-  write('|'), 
						afficherElement(E),
						afficherListe(L).
afficherElement([]):- write(' '),!.
afficherElement(E):- write(E).
