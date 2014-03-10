#!/bin/bash
# biafra ahanonu
# started: 2013.06.17
# changelog
	# 2014.02.02 - updated find so it goes by depth in reverse order

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
	echo -e 'folder lowercaser v1.0 by biafra ahanonu\n'
	echo -e 'lowercaseFolders.sh -options'
	echo 'OPTIONS'
	echo -e '\t-d DIRECTORY : lowercases folders in DIRECTORY'
	echo -e '\t-h/-help : displays help (little catch-22)'
	echo 'DIRECTORY defaults to ./ (current dir) unless specified. Full paths are stored in log file.'
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
				lowerCase
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
lowerCase(){
	separator
	# to read in directories with spaces
	oldIFS=$IFS;
	# change internal file separator
	IFS=$(echo -en "\n\b");
	# find the max depth in the file list, thanks Sorpigal for the concise function (http://stackoverflow.com/questions/4329369/recursive-function-to-return-directory-depth-of-file-tree)
	maxDepth=$( find ./ -type d -exec bash -c 'echo $(tr -cd / <<< "$1"|wc -c):$1' -- {} \; | sort -n | tail -n 1 | awk -F: '{print $1}' )
	# rename files in depth order to avoid move errors (e.g. directory does not exist)
	fileList=$( depth=$maxDepth; while find -mindepth $depth -maxdepth $depth -type d | grep --color=never '.'; do depth=$((depth - 1)); done )
	# fileList=$( `find * -depth -type d` )
	# loop through all directories
	for x in $fileList; do
		y=$(echo $x | tr '[A-Z]' '[a-z]' | sed 's/ /_/g;s/,//g');
		echo $y;
		check=$(echo ${y%/*});
		# if [ ! -d $check ]; then
		# 	echo '!dir skipping... | '$check ;
		# 	continue;
		# fi;
		if [ "$x" != "$y" ]; then
			mv "$x" "$y";
			echo "$x to $y";
		fi;
	done;
	# reset internal file separator
	IFS=$oldIFS
}

#run script
getArgs $@