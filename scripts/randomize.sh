# !/bin/bash
# biafra ahanonu
# updated: 2013.06.14
# randomly rename files in directory and convert back when needed; the extensions of the files are conserved during the change.

#TODO:
	# add option (-i) to hide output
	# allow regexp option (-r) via sed filter or other to allow only particular files to be chosen
	# test with foreign characters (e.g. é, ñ, etc.)

#Reset if getopts was used previously
OPTIND=1

getArgs(){
	# branches script based on input options
	# list of options, colon signifies options that should have an argument after
	optionsCheck=":hd:e:"
	# if no input...
	if [[ -z $1 ]]; then
		echo "Please enter an argument"
		separator
		viewHelp
		exit 0
	fi
	# check if directory set, else use local folder
	# ${!#}
	if [ -z "$3" ]; then
		usrDir="./"
	elif [[ $3 ]]; then
		usrDir=$3
	fi
	# branch based on options
	while getopts $optionsCheck opt; do
		case "$opt" in
			h|\?)
				viewHelp
				exit 0
				;;
			e)
				logfile=$OPTARG
				encode $logfile $usrDir
				;;
			d)
				logfile=$OPTARG
				decode $logfile $usrDir
				;;
			*)
				echo "Please enter an argument"
				exit 0
				;;
		esac
	done
	# shift off the options and optional --.
	shift $((OPTIND-1))
}
viewHelp(){
	# help documents, called in getArgs
	echo -e 'file hasher v1.0 by biafra ahanonu\n'
	echo -e 'randomize.sh -options [DIRECTORY]\n'
	echo 'DIRECTORY defaults to ./ (current dir) unless specified. Full paths are stored in log file.'
	echo 'OPTIONS'
	echo -e '\t-e [file] : randomly renames DIRECTORY files and stores hash in [file]'
	echo -e '\t-d [file] : reads hashes from [file] and renames DIRECTORY files accordingly'
	echo -e '\t-h/-help : displays help (little catch-22)'
}
encode(){
	# randomize files inside a folder and store log in above folder
	# Get absolute path to improve later decoding
	usrDir=`cd $2; pwd`/
	# !clear/create new log file
	logfile=$usrDir$1;rm $logfile;touch $logfile
	echo 'encoding files...log is '$logfile
	# get extension and base for log file
	ext=${logfile##*.};fbname=${logfile%.*}
	# loop over each file, get random number and rename
	separator
	for oldFile in $( find $usrDir -maxdepth 1 -type f ); do
		if [[ "$oldFile" == *"$logfile"* ]]; then
			continue
		fi
		# get old file extension to preserve
		ext=${oldFile##*.}
		# use $RANDOM to generate random, extension preserved filename
		randomFile="$usrDir$RANDOM"."$ext"
		# ...
		mv $oldFile $randomFile
		# mv $oldFile oldfiles/$oldFile
		echo -e $oldFile"\t"$randomFile >> $logfile
		echo $oldFile -\> $randomFile
	done
	separator
	echo "-encoding finished, log stored in $logfile"
	echo "-to decode, type: randomize.sh -d $logfile"
}
decode(){
	# convert files in the log back to their original form
	echo 'decoding files from '$2$1
	logfile=$2$1
	# read each line of log, print out conversion then pass a mv command to system
	separator
	gawk '{print $2" -> "$1; system("mv "$2" "$1)}' $logfile
	separator
	echo 'Decoded files!'
}
separator(){
	# standardize separator output...
	echo "---------------------"
}
#run script
getArgs $@