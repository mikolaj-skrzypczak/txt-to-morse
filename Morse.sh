#!/bin/bash

function show_help {
    echo "Skrypt Morse.sh sluzy do zamiany tekstu na kod w alfabecie morse'a"
    echo "Uzyty bez przelacznikow, przetlumaczy otrzymany tekst i wyswietli go na standardowym wyjsciu"
    echo "Dostepne sa nastepujace przelaczniki:"
    echo "	-h/--help  : wyswietl pomoc"
    echo "	-r/--readfrom filename : odczytanie danych z pliku zamiast stdin"
    echo "	-w/--writeto filename : zapisanie wyjscia do pliku zamiast stdout"
    echo -E "	-a/--alfabet filename : zdefiniuj wlasna reprezentacje alfabetu morse'a, example: word'\s'translation'\n'"
    echo "	-v/--verbose : przelacznik na wydawanie dzwiekow"
}

if [[ ! $1 ]]; then
    show_help
    exit 1
fi

str="a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 \. \, \! \?"
znaki=($str)
str=".- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --.. .---- ..--- ...-- ....- ..... -..... --... ---.. ----. ----- .-.-.- --..-- .---. ..--.."
tlumaczenie=($str)

function morse {
    foo="$@"
    for (( i=0; i<${#foo}; i++ )); do
	char="${foo:$i:1}"
	j=0
	char=$(echo "$char" | tr 'A-Z' 'a-z')
	flag="0"
	while [[ $j -lt ${#znaki[@]} ]]; do
	    if [[ $char == ${znaki[$j]} ]]; then
		echo -n "${tlumaczenie[$j]} " 
		flag="1"
	    fi
	    j=$(( $j + 1 ))
	done
	if [[ $char == " " ]]; then
	    echo -n -e "      "
	    flag="1"
	elif [[ $char == "\\" ]]; then
	    echo -n -e "      "
	    i=$(($i + 1))
	    flag="1"
	fi
	if [[ ! -z $char && $flag == "0" ]]; then
	    echo -n "#"
	fi
    done
    echo
}

OLD_IFS=$IFS
function alfabet {
    str1=""
    str2=""
    znaki=NULL
    tlumaczenie=NULL
    while IFS= read -r line; do
	znak=$(echo "$line" | awk '{ print $1 }')
	przetlumaczony=$(echo "$line" | awk '{print $2}')
	str1="$str1 $znak"
	str2="$str2 $przetlumaczony"
    done < "$1"
    znaki=($str1)
    tlumaczenie=($str2)
}
function odczyt {
    plik="$1"
    str=""
    while IFS= read -r line; do
	str="$str$line "
    done < "$1"
    echo "$str" | rev | cut -c 3- | rev	
}
function BEEP {
    rm dot.wav 2>/dev/null
    rm line.wav 2>/dev/null
    rm pauza.wav 2>/dev/null
    ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.1" dot.wav 2>/dev/null
    ffmpeg -f lavfi -i "sine=frequency=1000:duration=0.3" line.wav 2>/dev/null
    ffmpeg -f lavfi -i "sine=frequency=0:duration=0.1" pauza.wav 2>/dev/null
    cat /dev/null > sounds
    foo=$WYNIK
    for (( i=0; i<${#foo}; i++ )); do
	char="${foo:$i:1}"
	if [[ $char == "." ]]; then
	    echo "file 'dot.wav'" >> sounds
	    echo "file 'pauza.wav'" >> sounds
	elif [[ $char == "-" ]]; then
	    echo "file 'line.wav'" >> sounds
	    echo "file 'pauza.wav'" >> sounds
	else
	    echo "file 'pauza.wav" >> sounds
	fi
    done
    rm output.wav
    ffmpeg -f concat -i sounds -c copy output.wav 2>/dev/null
    aplay -q output.wav
}
while [[ $# -gt 0 ]]; do
    case "$1" in
	-h|--help)
	    shift
	    show_help
	    ;;
	-r|--readfrom)
	    shift
	    czytamy=true	    
	    plik_do_odczytu=$(odczyt "$1")	    
    	    shift
	    ;;
	-w|--writeto)
	    shift
	    zapisujemy=true
	    plik_do_zapisu="$1"
	    shift
	    ;;
	-a|--alfabet)
	    shift
	    wlasny_alfabet=true
	    plik_z_alfabetem="$1"
	    shift
	    alfabet "$plik_z_alfabetem"
	    ;;
	-v|--verbose)
	    shift
	    mowimy=true
	    ;;
	*)
	    break
	    ;;
	esac
done


if [ "$czytamy" = true ]; then
    WYNIK=$(morse "$plik_do_odczytu")
else
    WYNIK=$(morse "$@")
fi
if [ "$zapisujemy" = true ]; then
   echo "$WYNIK" > $plik_do_zapisu
else
    echo "$WYNIK"
fi
if [ "$mowimy" = true ]; then
    BEEP
fi
