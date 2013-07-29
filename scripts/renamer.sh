#!/bin/bash
# biafra ahanonu
# updated: 2013.06.17
# Script to automate regexp replacement of filenames
# Currently operates on all files in a directory
# Features to add
	# Type of file (.mp3, .txt, etc.)
	# regexp of files to actually change

# # Ask user for directory
# echo "Directory? "
# read userDir
# cd $userDir  

# Yes/No function
getYesNo(){
	select terminateSignal in "Yes" "No"
	do
		case $terminateSignal in
			"Yes" )
				return 1;;
			"No" ) 
				return 0;;  
		esac
	done	
}
viewHelp(){
	# help documents, called in getArgs
	echo -e 'file renamer v1.0 by biafra ahanonu\n'
	echo -e 'renamer.sh -options'
	echo 'DIRECTORY defaults to ./ (current dir) unless specified. Full paths are stored in log file.'
	echo 'OPTIONS'
	echo -e '\t-d DIRECTORY : renames files in DIRECTORY'
	echo -e '\t-h/-help : displays help (little catch-22)'
}
separator(){
	# standardize separator output...
	echo "---------------------"
}
getArgs(){
	# branches script based on input options
	# list of options, colon signifies options that should have an argument after
	optionsCheck=":hd:"
	# if no input...
	if [[ -z $1 ]]; then
		echo "Please enter an argument"
		separator
		viewHelp
		exit 0
	fi
	# check if directory set, else use local folder
	# ${!#}
	if [ -z "$2" ]; then
		usrDir="./"
	elif [[ $2 ]]; then
		usrDir=$2
	fi
	echo $usrDir
	# branch based on options
	while getopts $optionsCheck opt; do
		case "$opt" in
			h|\?)
				viewHelp
				exit 0
				;;
			d)
				cd $usrDir
				renameFile
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
renameFile(){
	# Change file separator to allow use of files with spaces
	oldIFS=$IFS
	IFS=$(echo -en "\n\b")

	# Ask user if multiple regexp are wanted
	echo "number of regexp's (e.g. 3)? "
	read regexpNum  
	echo "_______"

	# Loop through until user has entered all regexp
	for (( i = 0; i < $regexpNum; i++ )); do
		# Get regexp to replace
		echo "Enter replacing regexp #"$i": "
		read oldRegexp
		# Get string to replace with
		echo "Enter string #"$i" to replace with: "
		read newRegexp

		# Store in an array
		oldRegexpArray[$i]=$oldRegexp
		newRegexpArray[$i]=$newRegexp

		# Check against one of the files in the directory
		fileCheck=($(ls))
		echo ${fileCheck[0]} | sed 's/'${oldRegexpArray[$i]}'/'${newRegexpArray[$i]}'/g'
		
		# If not desired regexp, repeat
		getYesNo
		response=$?
		if [[ $response == 0 ]]; then
			i=$(expr $i - 1)
		fi
		echo "___"
	done

	# Compile all expressions into one sed regexp
	sedRegexp=""
	for (( i = 0; i < ${#oldRegexpArray[*]}; i++ )); do
		sedRegexp=$sedRegexp's/'${oldRegexpArray[$i]}'/'${newRegexpArray[$i]}'/g;'
	done
	# Remove trailing semicolon
	sedRegexpLen=${#sedRegexp}-1
	sedRegexp=${sedRegexp:0:sedRegexpLen}
	echo $sedRegexp
	echo "_______"

	# Ask user if changes look good, if not, restart script
	echo "Display results? "
	getYesNo
	displayResults=$?

	if [[ $displayResults == 1 ]]; then
		for oldfile in *
		do
			newname=$(echo $oldfile | sed $sedRegexp)
				echo "old: "$oldfile" | new: "$newname
		done
	fi
	echo "_______"

	# Ask user if changes look good, if not, restart script
	echo "Continue with renaming? If NO, script with restart. "
	getYesNo
	response=$?
	if [[ $response == 0 ]]; then
		bash batch_renamer.sh
	fi
	echo "_______"

	# Rename files
	for oldfile in *
	do
		newname=$(echo $oldfile | sed $sedRegexp)

		# If new and old name are the same, skip
		if [[ $oldfile == $newname ]]; then
			continue
		fi

		# Echo files being changed and change them
		if [[ $displayResults == 1 ]]; then
			echo $oldfile $newname
		fi
		mv $oldfile $newname
	done

	# Return file separator to default
	IFS=$oldIFS
}

#run script
getArgs $@