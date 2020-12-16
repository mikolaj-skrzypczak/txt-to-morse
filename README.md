# text_to_morse_code
Bash script converting text from arguments to morse code with a optional flag to play sounds, write output to .txt, read input from.txt or to set own alfabet.

code in Polish

### how to use
Simply execute the program and add the text you want to translate after it's name ./Morse.sh SOS

There are some optional flags you might want to use:
            -h/--help  : show help (in Polish)
            
            -r/--readfrom filename : load a message which is to be translated from a txt file
            
            -w/--writeto filename : write output to a txt file instead of to stdout
            
            -a/--alfabet filename : define your own alphabet from a txt file, where the formmating of the documment should look like: word'\s'translation'\n'
            
            -v/--verbose : flag to play the actual morse code using your speakers
            
