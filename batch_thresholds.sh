#! /bin/bash
#
# This script has been created to run the /usr/bin/singularity
# command and is designed to be run via qsub, as in:
#		qsub /path/to/scriptname
#
# The script can be customized as needed.
#
################################## START OF EMBEDDED SGE COMMANDS #######################
### SGE will read options that are treated by the shell as comments. The
### SGE parameters must begin with the characters "#$", followed by the
### option.
###
### There should be no blank lines or non-comment lines within the block of
### embedded "qsub" commands.
###
############################ Stadard parameters to the "qsub" command ##########
#### Set the shell (under SGE).
#$ -S /bin/bash
####
#### Run the commands in the directory where the SGE "qsub" command was given:
#$ -cwd
####
#### save the standard output. By default, the output will be saved into your
#### home directory. The "-o" option lets you specify an alternative directory.
#$ -o /cbica/home/sizemora/sge_job_output/singularity.$JOB_ID.stdout
#### save the standard error:
#$ -e /cbica/home/sizemora/sge_job_output/singularity.$JOB_ID.stderr
####
#### My email address:
#$ -M annsize@seas.upenn.edu
#### send mail at the beginning of the job
#$ -m b #### UNCOMMENT this line so that it begins with "#$" to enable SGE to send mail at the beginning of the job
#$ -m e #### UNCOMMENT this line so that it begins with "#$" to enable SGE to send mail at the end of the job
#$ -m a #### UNCOMMENT this line so that it begins with "#$" to enable SGE to send mail in case the job is aborted
##################################
#### Optional SGE "qsub" parameters that could be used to customize
#### the submitted job. In each case, remove the string:
####		REMOVE_THIS_STRING_TO_ENABLE_OPTION
#### but leave the characters:
#### 		#$
#### at the beginning of the line.
####
####
### Indicate that the job is short, and will complete in under 15 minutes so
### that SGE can give it priority.
### 	WARNING! If the job takes more than 15 minutes it will be killed.
#REMOVE_THIS_STRING_TO_ENABLE_OPTION$ -l short
####
####
#### Request that the job be given 6 "slots" (CPUS) on a single server instead
#### of 1. You MUST use this if your program is multi-threaded, you should NOT
#### use it otherwise. Most jobs are not multi-threaded and will not need this
#### option.
#REMOVE_THIS_STRING_TO_ENABLE_OPTION$ -pe threaded 6
####
####
####
#### The "h_vmem" parameter gives the hard limit on the amount of memory
#### that a job is allowed to use. As of July, 2012, that limit is
#### 4GB. Please consult wit the SGE documentation on the Wiki for
#### current informaiton.
####
#### In order to use more memory in a single job, you MUST set the
#### "h_vmem" parameter. Jobs that exceed the "h_vmem" value (by even
#### a single byte) will be automatically killed by the scheduler.
####
#### Setting the "h_vmem" parameter too high will reduce the number
#### of machines available to run your job, or the number of instances
#### that can run at once.
####
####
#$ -l h_vmem=10G
####
################################## END OF DEFAULT EMBEDDED SGE COMMANDS###################


# Send some output to standard output (saved into the
# file /cbica/home/sizemora/sge_job_output/singularity.$JOB_ID.stdout) and standard error (saved
# into the file /cbica/home/sizemora/sge_job_output/singularity.$JOB_ID.stderr) to make
# it easier to diagnose queued commands

/bin/echo "Command: /usr/bin/singularity"
/bin/echo "Arguments: exec noise-and-tda-latest.sif julia --color\=yes code/run_ph_forward.jl config090820.json"
/bin/echo -e "Executing in: \c"; pwd
/bin/echo -e "Executing on: \c"; hostname
/bin/echo -e "Executing at: \c"; date
/bin/echo "----- STDOUT from /usr/bin/singularity below this line -----"

/bin/echo "Command: /usr/bin/singularity" 1>&2
/bin/echo "Arguments: exec noise-and-tda-latest.sif julia --color\=yes code/run_ph_forward.jl config090820.json" 1>&2
( /bin/echo -e "Executing in: \c"; pwd ) 1>&2
( /bin/echo -e "Executing on: \c"; hostname ) 1>&2
( /bin/echo -e "Executing at: \c"; date ) 1>&2
/bin/echo "----- STDERR from /usr/bin/singularity below this line -----" 1>&2

configfile="config090920.json"

for graph in processed_data/graphs/70nodes/*
do
    # Run PH and save PH
    echo $graph
    qsub code/run_ph_thresholds.sh $graph $configfile
    qsub code/run_ph_noiseOnly.sh $graph $configfile

done

# /usr/bin/singularity exec noise-and-tda-latest.sif julia --color\=yes code/run_ph_forward.jl config090820.json