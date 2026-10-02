#!/bin/bash
#If you redistribute this script or want to use it - do it under GPL3 License. See copy here:
#https://www.gnu.org/licenses/gpl-3.0.html

#in seconds
open_ssl_timeout=10

SERVERS=(
    "https://rfc3161.ai.moda/any"
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
    "https://rfc3161.ai.moda"
    "https://rfc3161.ai.moda/adobe"
    "https://rfc3161.ai.moda/microsoft"
    "https://rfc3161.ai.moda/apple"
    "https://rfc3161.ai.moda/any"
    "http://rfc3161.ai.moda"
    "http://timestamp.digicert.com"
    "http://timestamp.globalsign.com/tsa/r6advanced1"
    "http://rfc3161timestamp.globalsign.com/advanced"
    "http://timestamp.sectigo.com"
    "http://timestamp.apple.com/ts01"
    "http://tsa.mesign.com"
    "http://time.certum.pl"
    "https://freetsa.org"
    "http://tsa.startssl.com/rfc3161"
    "http://dse200.ncipher.com/TSS/HttpTspServer"
    "https://ca.signfiles.com/tsa/get.aspx"
    "http://services.globaltrustfinder.com/adss/tsa"
    "https://tsp.iaik.tugraz.at/tsp/TspRequest"
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
    "http://timestamp.acs.microsoft.com"
)


#echo choice $@

if test "$*" = "-h"; then
echo "
This is help message.
This script requires two things as arguments:
1. File that contains blueprint, or a Directory that contains all blueprints.
2. Location/name of file where blueprints will be stored into. It will also come save some helper files into same location.
If location is not given - script will try to create one.

What is this argument word? Its basically a word you put after you typed in this command.
In computers, when comes to running programs and commands it usually means some additional parameter, like a name, or a date or a file name. Something that would help command/script to work or give it idea what it deals with/works with.
In this specific case, first argument has to be - either your blue print file OR name of folder where all of your blueprints are. Be careful, anything not in this file or argument - will not be addressed at later stage.

Second argument - is location where archive of your blueprint will be stored. It could be some directory on your computer OR it could be your USB flash drive or it coul be something similar. You can give a non existing directory name to this archive of your blueprint, and $0 will try to create it.

"
elif test "$*" = "-a"; then
echo "
About this script:

This script is designed to create limited help to Inventors.
Invetors often use computer to create and store their blueprints for their projects.
Sometimes some companies will use patents to intentionally(bullies, called \"Patent Trolls\") or unintentionally make lives of Inventors worse. I won't go in details what Patents and Patent Trolls are. Needless to say, what this script is trying to do - it tries to prove to rest of the world(including patent office and courts), that the blueprint that inventor was creating and modifying - actually existed for long(er) time, potentially longer that patent in question. Which can save Inventor a lot of legal and financial head aches.

This script and concept is work in progress. It could use some help, especially from seasoned patent lawyers.(yeah right... Like they will help for free to a an Open Source  project of unemployed technical engineer)

Please read Readme.md file for more information.

In a nutshell, this script will create archive of your blueprint, in the state that this script found your blueprint. Make sure to save your work right before you use this script! It will also create helper files. Save them together with archive of your blueprint!(for convenience, strongly recommended)

Once such archive is created(which has copy of your blueprint inside of it! back it up!!!) - it will create a so call call digest

TO BE CONTINUED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

It's very important for you to copy new files to other place than your computer. Ideally copy it to safe place where no one can get it but yourself. If you don't do that - this can possibly get you in trouble at later stage. Not having those files when you need them is a "bummer".
It is VERY recommended to put your bluprint into safe place. Consider outside of your home/building perhaps, in case if your house catches fire or gets flooded.(But we certainly hope it will never come to that! But you can never be too prepared).
Though you want to be carefull with moving copy outside of your house too. You don't want your blueprint to get into wrong hands!
Decisions, Decisions...

This script can be destributed as per GNU GENERAL PUBLIC LICENSE. Its free to use!
https://www.gnu.org/licenses/gpl-3.0.html
"

elif test -n "$*" ;then
echo "given blueprint(s) to work with: $@
Starting compression, depending on how big your blueprints are - this may take a while.
Creating folder for future archive:
"
#taking idea from intput what we are protecting
whattosave="$@"
#creating name of folder which we will use for saving new archive
wheretosave="$whattosave"_"$(date +%Y-%m-%d--%H-%M)"
#creating said folder where we will keep blueprint.
mkdir -p "$wheretosave"
#copying to be archived data into future archive folder
if cp -avr "$whattosave" "$wheretosave" ; then : ; else echo failed to copy blueprints. Check permissions of files, if your user can operate them. Script DID NOT work as intended. ; exit ; fi
#archiving blueprint copy.
if tar -czvf "$wheretosave".tar.gz  "$wheretosave"; then
echo succesfully created archive of your blueprint.
ls "$wheretosave"
echo cleaning up after ourself.
rm "$wheretosave/" -rv;
mkdir -p "$wheretosave/"

mv "$wheretosave".tar.gz "$wheretosave" -v
else echo Failed to create archive. Exiting with error. Script DID NOT work as intended.
exit 1
fi
#we shall call this fucntion later to accomodate trust chain collection/verification.
function collect_trust_chain(){
	#unreliable, but MUCH better than nothing. In cryptography/law... Can't believe I am saying it.
	collected_chain_from_TLS=$(timeout "$open_ssl_timeout"s openssl s_client -showcerts -connect "$@" <<< /dev/null)
	printf "%s\n" "$collected_chain_from_TLS" >> "$wheretosave/$current_domain$i.txt"
#	cat "$wheretosave/$current_domain$i.txt"
	echo TLS Certificate\(s\) are save here\: "$wheretosave/$current_domain$i.txt"

}

#creating time stamp server request 
#openssl ts -query -data "$wheretosave"/"$wheretosave".tar.gz sha3-512 -out "$wheretosave"/"$wheretosave".tar.gz.ts
#creating digest that we later submit to TimeStamp(TS) server.
#openssl  dgst -hex -sha3-512  -out "$wheretosave"/"$wheretosave".tar.gz.dgst  "$wheretosave"/"$wheretosave".tar.gz
if openssl ts -query -data "$wheretosave"/"$wheretosave".tar.gz  -sha-256 -out "$wheretosave"/"$wheretosave".tar.gz.ts ; then  echo created ts request; else echo failed to create time stamp request. Script DID NOT work as intended. ; fi
#openssl ts -query -data "$wheretosave"/"$wheretosave".tar.gz  -sha3-512  -out "$wheretosave"/"$wheretosave".tar.gz.ts
for i in "${!SERVERS[@]}"; do
{
    url="${SERVERS[$i]}"
    echo "Attempting hit #$i on: $url"

    # We use the index $i to give each response a unique name: response_0.ts, response_1.ts, etc.
    if curl   --connect-timeout 20 -H "Content-Type: application/timestamp-query"  --data-binary "@$wheretosave/$wheretosave.tar.gz.ts" "$url" -o "$wheretosave/$wheretosave.tar.gz.ts_response$i" ; then
    readlink -f "$wheretosave/$wheretosave.tar.gz.ts_response$i"
	#openssl ts -verify -in "$wheretosave"/"$wheretosave.tar.gz.ts_response"
	# this works - openssl ts -reply -in  /home/dimko/work/Darth_Frog/todo.txt_2026-09-30--23-00/todo.txt_2026-09-30--23-00.tar.gz.ts_response11  -text
	echo "$url" >> "$wheretosave/url$i.txt"
	echo URL that was used is "$url" and where its supposed to be saved: "$wheretosave/url$i.txt"
	#while at it, lets try to collect SSL certs of TSA servers, where possible.
	if grep "https://" <<< "$url" ; then
	echo attempting to collect SSL certificates from HTTPS enabled Time Stamp Server "$url" , to make life of defensive solicitors and defence vitnesses easier.
	current_domain=$(sed 's|https://||' <<< $url)
	current_domain=$(sed 's|/.*||' <<< $current_domain)
	echo "$url"|sed 's|/.*||'
	#need to make sure that URL doesnt already use non standard port. will add if statement later
	current_domain="$current_domain"':443'
	echo working on domain "$current_domain"
	collect_trust_chain "$current_domain"

#	collected_chain=$(openssl s_client -showcerts -connect "$current_domain" 2>>/dev/null)
#	printf "%s\n" "$collected_chain" >> "$wheretosave/$current_domain$i.txt"
	fi
    else
        echo "FAILURE: $url is not accessible. Likelt TSA web server is dead."
    fi
}
done





else
echo "
Hello Inventor/Admin!
For help how to use this script type in: $0 -h
To learn about this script type in: $0 -a
As much as we want to help you - we can not be responsible for this software. Especially anything to do with legal part of it. We are not responsible for anything bad associated with it. We do our diligence to make sure it does not harm you. But legal questions are difficult and not they are not technical area of expertise. Script is a software. And all relatively advanced software, even if its small one, like ours - usually has some(hopefully small) bugs/problems. We provide this script for free in hope to make your life better/easier - but we can not promise it won't make your life worse. And we will try to fix it when we can, if we find anything unusual with it. Please report it here:

"
fi
