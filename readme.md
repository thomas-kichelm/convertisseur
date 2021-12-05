
# Generation de page HTML :


## 1 : notice rédigée à l’attention des utilisateurs :

le script convertisseur.sh permet de générer un site web de plusieurs pages chacunes
résument un cours contenant une page d’un fichier pdf et un extrait audio du cours.

Pour cela il faut spécifier dans un fichier le ‘storyboard’ du projet sous cette forme :

titre,fichier.pdf,<n° de page>,extrait_audio.amr,<debut_enregistrement>,<durée>
_<debut_enregistrement> et <durée> sont exprimé sous cette forme
(‘minutes :secondes.centiemes‘)_

exemple :
		Un,pres.pdf,1,exemple.amr,0:4.78,0:4.
		Deux,pres.pdf,2,exemple.amr,0:11,0:
		Trois,pres.pdf,3,exemple.amr,0:19,0:
		Quatre,pres.pdf,4,exemple.amr,0:37,0:
		Cinq,pres.pdf,4,exemple.amr,0:46,0:
		l’extrait audio doit impérativement être au format amr_

le script s’utilise de la façon suivante :
./convertisseur.sh -f <source> -t <destination> [-s]
<source> est le fichier storyboard
<destination> est le fichier qui sera crée et ou se trouveront les pages html

./convertisseur.sh -h
affiche une page d’usage

## 2 : page de manuel succincte

Usage:
./convertisseur.sh -f <source> -t <destination> [-s]
./convertisseur.sh -h
— -f <source> permet de spécifier le storyboard.
— -t <destination> permet de spécifier le dossier de destination.
— -s indique que nous souhaitons ouvrir la 1ere page dans le navigateur par d
́efaut de l’utilisateur.
— -h Affiche l’aide d’utilisation.


## 3 : notice de documentation à l’usage des programmeurs :

A) Principes généraux de fonctionnement du programme


ce programme fonctionne de la façon suivante :
les options saisies par l’utilisateur sont gérées et affectées à des variable
dans des ‘case’ dans le corps du script en lui même.
Si il y a 4 ou 5 option et les option -t en 1ère position et -s en 3ème
position alors ont appelle la fonction main.
Cette fonction s’occupe d’appeler toutes les fonction utiles au
programme dans l’ordre.

De plus dans ce programme un format de log est utilisé pour informer
l’utilisateur des opération en cours chaque opération ajoutée par la suite doit
donc utiliser ce format de log :

en début d’opération
`echo "[$(date +"%I:%M:%S %p")] <description de l’action>"`

et en fin d’opération :
echo "[$(date +"%I:%M:%S %p")] <description de l’action> effectué"

Les erreurs doivent etre afficher de la façon suivante à l’utilisateur (en utilisant les
variables déjà definies):

- un warning doit être affiché en orange
- une erreur bloquant l’exécution du programme doit être affichée en
rouge

B) Fichiers et structures de données :

la fonction parsing_storyboard remplie les tableaux :
tab_title, tab_pdf, tab_pages_pdf, tab_audio, tab_audio_start et tab_audio_duration

ce qui permet d’avoir acces aux informations saisies pour l’utilisateur dans le fichier
storyboard plus facilement

C) découpage en fonctions :



Afin d’améliorer la lisibilité du script toute les opération qui le peuvent doivent
être découpées en fonction.

## 4 : compte rendu de test :

scenarios qui conduisent à des erreurs non résolues :


si le fichier storyboard n’est pas formaté correctement on a une erreur.
Solutions :
pour remédier à cela il faudrait créer une fonction verify_storyboad qui vérifie
son bon format et son intégrité.

améliorations possible :

- améliorer la modularisation et la lisibilité générale du script
- utiliser getopts pour la gestion des options

[f]: #ui "zrfzfzfr"
[frz]: ## 1 : notice rédigée à l’attention des utilisateurs : "ou"
