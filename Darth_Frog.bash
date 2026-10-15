#!/bin/bash
#If you redistribute this script or want to use it - do it under GPL3 License. See copy here:
#https://www.gnu.org/licenses/gpl-3.0.html



#in seconds, making sure we are not stuck for long time with one unresponsive server.
open_ssl_timeout=10
#minimum of succesful  attempts to contact TSA servers and getting response from. We only need one, but in court it looks better if there is more than one!
TSA_GOOD_RESPONSES=5
#list TSA servers script will attempt to contact.
#much obliged, https://gist.github.com/Manouchehri/fd754e402d98430243455713efada710
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
    "http://services.globaltrustfinder.com/adss/tsa"
    "https://tsp.iaik.tugraz.at/tsp/TspRequest"
    "http://timestamp.entrust.net/TSS/RFC3161sha2TS"
    "http://timestamp.acs.microsoft.com"
)





user_input=("$@")
current_date=$(date +%Y-%m-%d--%H-%M-%S)

echo current date/time $current_date
#we shall call this fucntion later to accomodate trust chain collection/verification.
function collect_trust_chain(){
	#unreliable, but MUCH better than nothing. In cryptography/law... Can't believe I am saying it. We depend on "lets throw the net, and we will catch many fish, and some will be good" approach. In the future, if project gets funded or supported by other organisations - we can make our own TSA server. For now free third parties are more than enough. We need one or two responses to proove things without reasonable doubt.
	collected_chain_from_TLS="$(timeout "$open_ssl_timeout"s openssl s_client -showcerts -connect "$@" <<< /dev/null)"
	printf "%s\n" "$collected_chain_from_TLS" >> "$backup_folder"/"$current_domain""$i"".txt"
#	cat "$wheretosave/$current_domain$i.txt"
	echo TLS Certificate\(s\) are save here\: "$backup_folder/$current_domain$i.txt"

}



function create_archive(){

#creating name of folder which we will use for saving new archive or raw file, duplicate of current blurprint/to be protected file.

#folder where bluprint copy and timestamps will be stored
#backup_folder="$whattosave_full"_"$whattosave"_"$current_date"
backup_folder="$whattosave_full"_"$current_date"
echo making folder "$backup_folder"
#creating folder where bluprint will be backed up and stored.
if mkdir -pv "$backup_folder" ; then echo folder is created or does exists: $backup_folder, good ; else echo folder where backup/signed data is supposed to be - failed to create, operation has failed. Script DID NOT work as intended.; exit 1; fi

#REMINDER - good idea, implement tar only for many small media files.
#REMINDER - need to allow user to sign specific string, not just file.


#not archiving data 
if test "$archive" = '';then
#REMINDER, I could combine if above and two if below. 
if cp -avr "$whattosave_full" "$backup_folder" ; then echo copied "$whattosave_full" to "$backup_folder"; else echo Script DID NOT work as intended.; exit 1; fi
if realpath -e "$backup_folder"/"$whattosave" ; then :; else echo checked if original to be signed file/blueprint is copied over.; fi 
backup_file="$backup_folder"/"$whattosave"
echo this is backup file: "$backup_file"
return 0


#checking if, "default" choice is used, which is to archive and back up data before timestamping it. files and folders act differently on Linux for purpose of tar.gz hence devision.
elif test "$archive" = '.tar.gz' && test -f "$whattosave_full"  && tar -czvf "$backup_folder/""$(basename "$whattosave")""$archive"  -C "$(dirname "$whattosave_full")" -- "$whattosave" ;then
#checking if user wants to back up/sign folder + archiving it.
#if tar -czvf "$backup_folder/""$(basename "$whattosave")""$archive"  -C "$(dirname "$whattosave_full")" -- "$whattosave" ; then
backup_file="$backup_folder"/"$whattosave""$archive"
echo archived successesfully
return 0

elif test "$archive" = '.tar.gz' && test -d "$whattosave_full" && echo backing up folder "$backup_folder/""$(basename "$whattosave_full")""$archive" && tar -czvf "$backup_folder/""$(basename "$(realpath -e "$whattosave_full")")""$archive"  -C "$(dirname "$whattosave_full")" -- "$whattosave" ;then
#checking if user wants to back up/sign folder + archiving it.
#if tar -czvf "$backup_folder/""$(basename "$whattosave")""$archive"  -C "$(dirname "$whattosave_full")" -- "$whattosave" ; then
backup_file="$backup_folder"/"$(basename "$whattosave")""$archive"
echo archived successesfully
return 0



else
echo Failed to archive. Script DID NOT work as intended.
exit 1

fi


#if #else echo FAILED to archive blueprint! Script DID NOT work as intended. 
#exit 1
#fi

echo DEBUG KIKLLING FUCNTIONHERE FOR NOW
exit 1
}



#need to add -t for tar only.
case "${user_input[0]}"  in
  "-h")
 
   echo "
Darth Frog - Digital Proof of Existence Tool

This tool creates a redundant, cryptographically signed archive of critical data—including blueprints, scientific research, engineering designs, or audit records—to establish verifiable proof of existence at a specific point in time.

USAGE:
  $0 [-r] <target>

ARGUMENTS:
  <target>    The file or directory containing the data to be protected.

OPTIONS:
  -r          RAW MODE: Must be the first argument. This hashes the target
                file directly without compression. Recommended for already-
                compressed media (MPEG, JPEG, MP3) to avoid redundant
                processing.

OUTPUT:
  The script automatically creates a uniquely named folder in the same
  directory as your target (e.g., "filename_YYYY-MM-DD--HH-MM-SS").
  All archives and timestamp tokens will be stored inside this folder.

IMPORTANT NOTICE:
  To ensure the highest level of legal and scientific validity, ensure
  all work is fully saved and closed by your applications before running
  this script. Timestamping unsaved or temporary data may result in
  invalid or inadmissible evidence.


"

exit 0
    ;;
  "-a" )

    cat << 'EOF'

ABOUT DARTH FROG 

MISSION:
  Darth Frog is a high-integrity utility designed to establish verifiable 
  digital provenance. It allows users to create cryptographically signed 
  archives of data, providing an immutable, RFC 3161-compliant proof of 
  existence at a specific point in time.

PRIMARY USE CASES:
  - Patent & IP Defense: Protecting inventions and designs from patent 
    trolls and unauthorized infringement claims.
  - Scientific Priority: Establishing the exact moment of discovery or 
    research results to protect academic and scientific priority.
  - AI & Machine Learning Defense: Providing a cryptographic claim of
    ownership to combat unauthorized AI training, scraping, and 
    imitation of intellectual property.
  - Audit & Compliance: Ensuring the integrity of technical records, 
    logs, and engineering data for regulatory and forensic audits.

HOW IT WORKS:
  1. ARCHIVING: The target file or directory is compressed into a 
     highly stable .tar.gz archive.
  2. HASHING: A unique SHA-256 fingerprint (digest) is generated for 
     that archive.
  3. TIMESTAMPING: This fingerprint is sent to multiple global 
     Time Stamping Authorities (TSAs) via the RFC 3161 protocol.
  4. PROOF GENERATION: The TSAs return digitally signed tokens. These 
     tokens, when combined with your archive, create a mathematically 
     indisputable record of your data's existence.

DATA INTEGRITY & REDUNDANCY WARNING:
  - SOURCE INTEGRITY: The validity of the proof depends on the integrity 
    of the source data. Ensure all files are saved and closed before 
    execution.
  - SEPARATION OF STORAGE: To prevent total data loss, NEVER store your 
    timestamped archives in the same physical or logical location as 
    your original blueprints.
  - REDUNDANT BACKUPS: It is strongly recommended to store your archives 
    on multiple, separate media (USB, Cloud, etc.).

STATUS:
  This is an active development project. The core cryptographic engine 
  is operational.

LICENSE:
  Distributed under the GNU GENERAL PUBLIC LICENSE (GPLv3).

EOF


exit 0
    ;;

  "-r")
    unset user_input[0]
 	archive=''

	if realpath -e "${user_input[@]}" && test -f "${user_input[@]}" ; then echo file "$(realpath -e "${user_input[@]}")" - exists, continuing; else echo file realpath -e "${user_input[@]}" does not exist or is a folder. "RAW" fucntionality is not supported for folder at this time. Script DID NOT work as intended.; exit 1; fi
	
	whattosave="$(basename "${user_input[@]}")"
        whattosave_full="$(realpath -e "${user_input[@]}")"
	create_archive

    ;;
  *)
	archive='.tar.gz'
	if realpath -e "${user_input[@]}" ; then echo file "$(realpath -e "${user_input[@]}")" - exists, continuing; else echo file realpath -e "${user_input[@]}" does not exist. Script DID NOT work as intended.; exit 1; fi
	whattosave="$(basename "$(realpath -e "${user_input[@]}")")"
	whattosave_full="$(realpath -e "${user_input[@]}")"
	create_archive

    ;;
esac

function compare_req_resp() {
echo "Checking if response is describing request, by comaring send out and recieved message hashes.(what was actually timestamped).
It's very important check!"

#checking hash from response versus hash of query. It looks fragile, but in this specific case, I want to be wrong on safer side of things. If we have false negative in this check - its annoyance. If we have FALSE NEGATIVE HERE - "Huston, We got a problem!". I could use string manipulation here, to get hashes out and compare them. But its one of those "the less - is more" situations.
if [[ "$(openssl ts -reply  -in "$1"  -text |grep -A 2 'Message data:')" == "$(openssl ts -query -text -in "$2" |grep -A 2 'Message data:' )"  ]] ; then
echo Looks like hash from request to TSA server - matches hash from TSA server response. GOOD.
return 0
else echo There is a mismatch between response and request send to and from TSA server.
echo reply
openssl ts -reply  -in "$1"  -text |grep -A 2 'Message data:'
echo query
openssl ts -query -in "$2" |grep -A 2 'Message data:'
return 1
fi

}

function submit_recieve_TS(){

query_file="$backup_file".ts
if openssl ts -query -data "$backup_file" -cert -sha-256 -out "$backup_file".ts ; then  echo created ts request; else echo failed to create time stamp request. Script DID NOT work as intended. ; exit 1; fi
#openssl ts -query -data "$wheretosave"/"$wheretosave"  -sha3-512  -out "$wheretosave"/"$wheretosave".ts

#counting how many good TSA responses we got.
good_responses=0


#identifying storage of CA certs. there are two ways how CA are stored. Either bunch of many small file or new method, one big root CA file, that has many PEM root CA certs.
#we will need it for verification later. We use OS provided trusted CA collection. If its good enough for IBM or Ubuntu or Gentoo - it's good enough for us!

#this gives us immediate path to big CA collection file. Problem with this is that it MAY exist and yet not be used.
roots_file=$(python3 -c "import ssl; print(ssl.get_default_verify_paths().cafile)" 2>>/dev/null )
#checking if our python know where that giant CA storage is.
if realpath -e "$roots_file" 2>>/dev/null ; then
:
#if not finding giant file, alternative approach - we use older python method of finding storage/doing CA checksum validation.
#we find folder with CA root certs and there we seek for biggest file.
else
roots_file=$(python3 -c "import ssl; print(ssl.get_default_verify_paths().capath)" )
roots_file="$roots_file"/"$(ls -S1r $roots_file |tail -n1)"

if realpath -e "$roots_file" ; then echo we got root file "$roots_file"; else echo "we did not find root CA file from your OS. Please provide description of the OS in bug report."; return  1 ; fi

fi




for i in "${!SERVERS[@]}"; do
{
    url="${SERVERS[$i]}"
    echo "

    Attempting signing of data numer #$i on TSA server below:
    ^^^^$url^^^^

    "

    # We use the index $i to give each response a unique name: response_0.ts, response_1.ts, etc.
    if curl   --connect-timeout 20 -H "Content-Type: application/timestamp-query"  --data-binary "@""$query_file" "$url" -o "$query_file"_response_"$i" ; then
	echo got response into "$(readlink -e "$query_file"_response"$i")"
	
	# checking if response recieve was valid TSA server response, as per OpenSSL.
	if printf "\n\n" && openssl ts -reply -text -in "$query_file"_response_"$i" ; then
	if grep "Status: Granted." <<< $(openssl ts -reply -text -in "$query_file"_response_"$i") ; then : ; else echo recieved response showed no Granted status, skipping this TSA response. ; continue;  fi
	#if compare_req_resp "$query_file"_response_"$i"  "$query_file" ; then : ; else continue ; fi
	

	#openssl ts -reply -token_out -in "$query_file"_response_"$i" |openssl pkcs7 -inform der -print
	#documenting what URL wend into what respone. Number of responce corresponds to number of URL tried.
	echo "$url" >> "$backup_folder/url_$i.txt"
	echo URL that was used is "$url" and where its supposed to be saved: "$backup_folder/url_$i.txt"
	if openssl ts -verify  -data "$backup_file"  -in "$query_file"_response_"$i"  -CAfile "$roots_file" ; then
	echo "SUCCESFULLY VERIFIED RESPONSE FROM TSA SERVER AGAINST BUILT IN OS ROOT CA.
	This means that 3rd Party Time Stamping authority "$url" confirmed request.
	If you have one of those messages, or ideally more - there now exists evidence of your backed up blueprint on third party servers.
	It means, that whatever is in back up folder now - was created NOW and NOT AFTERWARDS. Don't worry, back up never left your computer!
	(at least not through this script)
	"
	#IDEA: generate README for every back up folder!!!!!
	


	else echo response from TSA server "$url"  was unverifiable. ;
	fi
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

	printf "\n\n  we have got at least one valid Time Stamp Response. Above."
	good_responses=$((good_responses + 1))
	else echo response did not seem to contain good data;
	fi
	


    else
        echo "FAILURE: $url is not accessible. Likely TSA web server is dead."
    fi
}
done

}

submit_recieve_TS


if test "$good_responses" -ge "$TSA_GOOD_RESPONSES"  ; then
:
else
echo "

We got only this ammount of good responses: "$good_responses". This appears to be not enough! Operation failed. Not enough working TSA servers can be reached.
Check your internet connection.
"
exit 1
fi


echo "


You may want to move or back up this folder: "$backup_folder" on a different storage(usb drive or something similar, don't loose it!!!)
Execution sucessfully completed.
"
exit 0


