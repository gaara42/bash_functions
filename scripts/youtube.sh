# /bin/bash

# biafra ahanonu
# updated: 2013.05.05
# youtube-dl wrapper script to help handle errors and automate some things

printHelp(){
	echo "youtube.sh FILE ARG
	ARG can be:
		-h for help
		-a for list of youtube URLs in a file, use only if filename contains 'http://'
		empty for single URL or file (auto-detects)"
	exit 0
}

# help string
helpString='-h -help --h --help'
# check if first argument contains a URL
URLcheck=$(echo $1 | grep 'http://' | wc -l)
# base command to use
baseCmd="youtube-dl -ixko %(title)s.%(ext)s --no-post-overwrites --verbose --restrict-filenames --audio-format mp3 -R 30 "

# check if first argument is a help string
if [[ "$helpString" == *"$1"* ]]; then
	printHelp
fi

# check if second arg is empty
if [ -z "$2" ]; then
	# If contains URL, do normally
	if [ $URLcheck -eq 0 ]; then
		cmd=$baseCmd"-a $1"
	# Enter batch mode if first arg is not URL
	elif [ ! $URLcheck -eq 0 ]; then
		cmd=$baseCmd"$1"
	fi
# User should flag with -a
elif [ $2 == -a ]; then
	cmd=$baseCmd"-a $1"
fi

echo $cmd

# continue until no error encountered
error=1
while [ $error -eq 1 ]; do
	# clear output file
	echo '' > youtube.output
	# save to file and output to cmd line, captures STDOUT and STDERR to allow restart of script if errors
	# $cmd | tee -ai youtube.output
	$cmd > >(tee -ai youtube.output) 2> >(tee -ai youtube.output >&2)
	# check if an error occurred, if so, restart script to resume download
	if [ $(grep 'ERROR' youtube.output | wc -l) -eq 0 ]; then
		echo No errors found, exiting...
		error=0
	else
		echo ________________________________________________________
		echo Errors found, restarting script...
		bash youtube.sh $1
	fi
done