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

elif test "$archive" = '.tar.gz' && test -d "$whattosave_full"  && tar -czvf "$backup_folder/""$(basename "$whattosave_full")""$archive"  -C "$(dirname "$whattosave_full")" -- "$whattosave" ;then
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

	unset $user_input[0]
	if realpath -e "${user_input[@]}" && test -f "${user_input[@]}" ; then echo file "$(realpath -e "${user_input[@]}")" - exists, continuing; else echo file realpath -e "${user_input[@]}" does not exist or is a folder. "RAW" fucntionality is not supported for folder at this time. Script DID NOT work as intended.; exit 1; fi
	
	whattosave="$(basename "${user_input[@]}")"
        whattosave_full="$(realpath -e "${user_input[@]}")"
	create_archive

    ;;
  *)
	archive='.tar.gz'
	if realpath -e "${user_input[@]}" ; then echo file "$(realpath -e "${user_input[@]}")" - exists, continuing; else echo file realpath -e "${user_input[@]}" does not exist. Script DID NOT work as intended.; exit 1; fi
	whattosave="$(basename "${user_input[@]}")"
	whattosave_full="$(realpath -e "${user_input[@]}")"
	create_archive

    ;;
esac


query_file="$backup_file".ts
if openssl ts -query -data "$backup_file"  -sha-256 -out "$backup_file".ts ; then  echo created ts request; else echo failed to create time stamp request. Script DID NOT work as intended. ; exit 1; fi
#openssl ts -query -data "$wheretosave"/"$wheretosave"  -sha3-512  -out "$wheretosave"/"$wheretosave".ts

for i in "${!SERVERS[@]}"; do
{
    url="${SERVERS[$i]}"
    echo "Attempting hit #$i on: $url"

    # We use the index $i to give each response a unique name: response_0.ts, response_1.ts, etc.
    if curl   --connect-timeout 20 -H "Content-Type: application/timestamp-query"  --data-binary "@""$query_file" "$url" -o "$query_file"_response"$i" ; then
	echo got response into readlink -e "$query_file"_response"$i"
	#openssl ts -verify -in "$wheretosave"/"$wheretosave.tar.gz.ts_response"
	# this works - openssl ts -reply -in  /home/dimko/work/Darth_Frog/todo.txt_2026-09-30--23-00/todo.txt_2026-09-30--23-00.tar.gz.ts_response11  -text
	echo "$url" >> "$backup_folder/url$i.txt"
	echo URL that was used is "$url" and where its supposed to be saved: "$backup_folder/url$i.txt"
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
        echo "FAILURE: $url is not accessible. Likely TSA web server is dead."
    fi
}
done

echo "


you may want to move or back up this folder: "$backup_folder" on a different storage(usb drive or something similar, don't loose it!!!)
Execution sucessfully completed.
"
exit 0


