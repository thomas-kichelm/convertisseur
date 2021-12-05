#!/bin/bash

# © THOMAS KICHELM & MATTHIEU ALCACERA (CC BY-NC 4.0)
set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# declare the color for the echo command
red='\e[0;31m'
orange='\e[0;33m'
cyan='\e[0;36m'
reset='\e[0;m'

# declare the arrays for parsing storyboard
declare -a tab_title
declare -a tab_pdf
declare -a tab_pages_pdf
declare -a tab_audio
declare -a tab_audio_start
declare -a tab_audio_duration

welcome(){

	: 'A function who print the title and the author off this script'

	echo -e "${cyan}   _____ ____  _   ___      ________ _____ _______ _____  _____ _____ ______ _    _ _____  
  / ____/ __ \| \ | \ \    / /  ____|  __ \__   __|_   _|/ ____/ ____|  ____| |  | |  __ \ 
 | |   | |  | |  \| |\ \  / /| |__  | |__) | | |    | | | (___| (___ | |__  | |  | | |__) |
 | |   | |  | | . \` | \ \/ / |  __| |  _  /  | |    | |  \___ \\___ \ |  __| | |  | |  _  / 
 | |___| |__| | |\  |  \  /  | |____| | \ \  | |   _| |_ ____) |___) | |____| |__| | | \ \ 
  \_____\____/|_| \_|   \/   |______|_|  \_\ |_|  |_____|_____/_____/|______|\____/|_|  \_\
                                                                                           
                                                                                           "

echo -e "© THOMAS KICHELM & MATTHIEU ALCACERA (CC BY-NC 4.0)\n $reset"
}
usage(){

	: 'a function who print the usage off the script
	'
	echo "Usage:
	./convertisseur.sh -f <source> -t <destination> [-s]
	./convertisseur.sh -h
	— -f <source> permet de spécifier le storyboard.
	— -t <destination> permet de sp´ecifier le dossier de destination.
	— -s indique que nous souhaitons ouvrir la 1ere page dans le navigateur par d´efaut de l’utilisateur.
	— -h Affiche l’aide d’utilisation."
}

create_dir(){

	: 'a function who create the directory specified by the user '

	echo  "[$(date +"%I:%M:%S %p")] creation du repertoire: $PWD/$dir"
	mkdir $dir #create the dir specified
	echo -e "[$(date +"%I:%M:%S %p")] le repertoire $PWD/$dir a ete cree avec succes\n"
}
verify_dir(){

	: ' a function who verify if the directory specified by the user exist and if necessary ask the user for delete him
		if the user answer is no the function raise an error and stop the execution
		otherwise it will call the function create_dir
		'
	echo "[$(date +"%I:%M:%S %p")] verification de l'existence du repertoir $PWD/$dir"
	if [ -d "$PWD/$dir" ] #if the dir existe
	then
		echo -e "${orange} le repertoire $PWD/$dir existe deja voulez-vous le supprimer ? (O/n)${reset}"
	       read user_response #ask for the user if he wont to delete the dir
       case $user_response in
	"O" | "o" )
		echo "[$(date +"%I:%M:%S %p")] suppression du repertoire $PWD/$dir"
		rm -r $dir;; #delete the dir and his evantual file
	*)
	#else raise an error
		echo -e "${red} erreur le repertoire $PWD/$dir ne peut pas etre supprimé${reset}">&2
		exit 1;;
	esac
	fi
	create_dir #all is set to call the create_dir func
}

parsing_storyboard(){

			: ' a function who parse the storyboard file specified by the user in arrays
				linked to the type off the element (example a title will go in tab_tittle)
		'

	echo "[$(date +"%I:%M:%S %p")] parsing du storyboard '$storyboard'"
	
	
		

	if [ -f $storyboard ] # if the storyboard specified exist continue else raise an error
	then 
		nb_line=1    # a var who will keep th number of the current line in the storyboard file
		for line in $(cat $storyboard) # for all the line of the storyboard file
			
	       	do
			for i in $(seq 1 $(($( cat $storyboard | wc -l)+3 )))# for i in [1,number of line of storyboard file] +2
				do
			           case $i in 
					   1)
						  tab_title[$nb_line-1]="$(echo $line | cut -d ',' -f $i)";;  # if i=1 stock the first element (who is the titled) in tab_title at the index of the current line
					   2)
						   tab_pdf[$nb_line-1]="$(echo $line | cut -d ',' -f $i)";;   # if i=2 stock the second element (who is the pdf file) in tab_pdf at the index of the current line

					 3)
					  tab_pages_pdf[$nb_line-1]="$(echo $line | cut -d ',' -f $i)";;  # if i=3 stock the third element (who is the page) in tab_pages_pdf at the index of the current line
					   4)
					tab_audio[$nb_line-1]="$(echo $line | cut -d ',' -f $i)";;        # if i=4 stock the 4th element (who is the audio file) in tab_audio at the index of the current line
					 5)
						 
				  tab_audio_start[$nb_line-1]="$(echo $line | cut -d ',' -f $i)";;    # if i=5 stock the 5th element (who is the start of the audio) in tab_audio_start at the index of the current line
			 	 6)
				  tab_audio_duration[$nb_line-1]="$(echo $line | cut -d ',' -f $i)";; # if i=6 stock the 6th element (who is the duration of the audio) in tab_audio_duration at the index of the current line
				esac
				
			     
	       		 done
		let nb_line=$nb_line+1
		 done
	else # raise an error if the storyboard doesn't exist
	echo -e "${red} erreur le fichier $PWD/$storyboard n'existe pas ${reset}">&2
                exit 1
	fi
	
	echo -e "[$(date +"%I:%M:%S %p")] parsing du storyboard '$storyboard' effectué\n"

	

}

pdf_to_img(){

		: ' a function who convert all the .pdf file off the project in .png
		'
	echo "[$(date +"%I:%M:%S %p")]conversion des fichier .pdf en .png" 
	for i in $(seq 1 $(($(cat $storyboard | wc -l )+1))) # for all the number of line in storyboard file 
	do	
	echo "		conversion de ${tab_pdf[$i-1]} en "$dir/pres-$((${i})).png""
	pdftoppm -png ${tab_pdf[$i-1]} "$dir/temp" -f  ${tab_pages_pdf[$i-1]} -l ${tab_pages_pdf[$i-1]} #convert the i-th page of tab_pages_pdf i-th pdf file of tab_pdf in temp.png 
	mv "$dir/temp-${tab_pages_pdf[$i-1]}.png" "$dir/pres-${i}.png" #rename temp.png in pres-i.png

done
echo -e "[$(date +"%I:%M:%S %p")]conversion des fichier .pdf en .png effectuée \n"

}

amr_to_ogg(){

		: ' a function who convert all the .amr file off the project in .ogg
		'

	echo "[$(date +"%I:%M:%S %p")]conversion des fichier .amr en .ogg" 
	for i in $(seq 1 $(($(cat $storyboard | wc -l )+1))) # for all the number of line in storyboard file
	do
		echo "		conversion de ${tab_audio[$i-1]} en $dir/pres-$i.ogg"
		ffmpeg -ss ${tab_audio_start[$i-1]} -t ${tab_audio_duration[$i-1]}  -i ${tab_audio[$i-1]} -ar 22050 $dir/audio$i.ogg  -loglevel quiet #convert the i-th audio tab_audio in audioi.ogg
	done
	echo -e "[$(date +"%I:%M:%S %p")]conversion des fichier .amr en .ogg effectuée\n" 
}

amr_to_mp3(){

		: ' a function who convert all the .amr file off the project in .mp3
		'

	echo "[$(date +"%I:%M:%S %p")]conversion des fichier .amr en .mp3" 
	for i in $(seq 1 $(($(cat $storyboard | wc -l )+1)))
	do 	     
	echo "		conversion de ${tab_audio[$i-1]} en $dir/pres-$i.mp3" 
	ffmpeg -ss ${tab_audio_start[$i-1]} -t ${tab_audio_duration[$i-1]}  -i ${tab_audio[$i-1]} -ar 22050 $dir/audio$i.mp3  -loglevel quiet #convert the i-th audio tab_audio in audioi.mp3
	done
	echo -e "[$(date +"%I:%M:%S %p")]conversion des fichier .amr en .ogg effectuée\n" 

}
create_summary(){
		: ' a function who create the summary page HTML for the project 
		'
	echo "[$(date +"%I:%M:%S %p")] creation du fichier $dir/sommaire.html"
	nb_file=$( ls $dir/*.html | wc -l) # a var who receive the number of html file in the directory
	touch $dir/sommaire.html           # create the summary.html file
	echo "<!DOCTYPE html>
                        <html>
                        <head>
                        <meta charset=\"utf-8\">
                        <title>Sommaire </title>
                        </head>
                        <body bgcolor="yellow">
                        <h1>Sommaire</h1>" >> $dir/sommaire.html # write the start of the summary.html file
	for i in $(seq 1 $nb_file) # for 1 to the number of html file in the directory
	do
		echo "<a href="page-$i.html">${tab_title[$i-1]}</a>"  >> $dir/sommaire.html #create a button with the title of the i-th page to go to this page

	done
	echo "</body></html>" >> $dir/sommaire.html #write the end of the summary.html file
echo "[$(date +"%I:%M:%S %p")] creation du fichier $dir/sommaire.html effectuée"

}
create_html(){

		: ' a function who create all the page HTML required by the project
		'
	echo "[$(date +"%I:%M:%S %p")] creation des fichiers html"
	
	for i in $(seq 1 $(($(cat $storyboard | wc -l)+1))) # for all the number of line in storyboard file (for all the page)
	do
	
	 
			
			echo "		creation du fichier $dir/page-${i}.html"

			# write the file with the i-th title the i-th audio
			echo "<!DOCTYPE html>
			<html>
			<head>
			<meta charset=\"utf-8\">
			<title>${tab_title[$i-1]} </title>
			</head>
			<body bgcolor="yellow">
			<h1>${tab_title[$i-1]}</h1>
			<img width="100%" src="pres-$i.png">
			<br/>
			<audio controls>
			<source src="audio$i.ogg" type="audio/ogg">
			<source src="audio$i.mp3" type="audio/mpeg">
			Your browser does not support the audio element.
			</audio>" >> $dir/page-$i.html
			
		
			if [ $i -ge 2 ] && [ $i -lt $(($(cat $storyboard | wc -l)+1)) ] #if the current page is beetween 2 an the number of line in the storyboard file
				then 
				#write a button previous to go to the i-th -1 page and a next button to go to the i-th +1 page
				echo "<a href="page-$(($i-1)).html">précédent</a> 
			<a href="page-$(($i+1)).html">suivant</a>
			</body>
			</html>" >> $dir/page-$i.html
			fi
			if [ $i = 1 ] #if the fist page is the current
			then
				 echo "
				 <a href="page-$(($i+1)).html">suivant</>
				</body	>
				 </html>" >> $dir/page-$i.html #only write previous button
			fi
			if [ $i = $(($(cat $storyboard | wc -l)+1))  ] #if the current page is the last page
			then
			 echo "<a href="page-$(($i-1)).html">precedent </body></html>" >> $dir/page-$i.html	#only write previous button
			fi

			
		done

	echo -e "[$(date +"%I:%M:%S %p")] creation des fichiers html executée\n"

}

launch_browser(){
	
	: 'a function who launch the first page HTML off the project with the default web browser'

	 echo "[$(date +"%I:%M:%S %p")] lancement du navigateur par defaut"
xdg-open $dir/page-1.html #launch the first page HTML off the project with the default web browser

}

main(){
	
	: 'the main function off the script who call all the function required by the program'
	
			verify_dir
			parsing_storyboard
			pdf_to_img
			amr_to_ogg
			amr_to_mp3
			create_html
			create_summary
}




welcome # at the start of the programm display the title the author and the license



case $# in 
	1 | 4 | 5) # if the user specified 1 or 4 or 5 option continue
		if [ $# -ge 1 ] #if the user specified 1 option
			then 
			option1=$1 #option1 equal to the first option specified by the user
		fi

		if [ $# -ge 4 ] #if the number of option specified by the user >=4 
		then
			storyboard=$2 #storyboard equal to the second option specified by the user
			option2=$3    #option2 equal to the third option specified by the user
			dir=$4        #dir equal to the 4th option specified by the user
		fi

		if [ $# -ge 5 ]
		then 
			nav=$5       #nav equal to the 5th option specified by the user
	
		fi
		;;
	*) #if the user don't specified 1 or 4 or 5 option raise an error
		echo -e " ${red} erreur: nombre d'option incorrect ! ${reset}" 
		usage >&2 
		exit 1;;

esac


case $option1 in 
	"-h") #if option1 = -h show usage
		usage;;
	"-f") #if option1 = -f show usage
		if [ "-t" = $option2 ] #and option2 = -t 
		then
			main
			if [ $# = 5 ] && [ "-s" = $nav ] #if nav = -s
			then
				launch_browser #call launch_browser
			fi
		else
			#else raise an error and show usage
			echo -e "${red} erreur: l'option -t est attendue ${reset}"
			usage >&2
			exit 1
		
		fi
		;;

	*) #else raise an error and show usage
		echo -e "${red} erreur: l'option: $option1 n'est pas valide !${reset}"
		usage >&2;;
	esac