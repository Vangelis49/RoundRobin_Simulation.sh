#!/bin/bash
#Hello World#
################################
#
#Testing for correct number of parameters
if test $# != 2
then
	echo "Wrong number of parameters"
	echo "do: ./scriptName fileName valueOfQuantum"
fi
################################
#
#Testing if the fileName is a regular file/Reading and storing the data in an array/storing parameter $2 into a variable
#Dividing the main  array into 3 different arrays
if test -f $1
then
	array=( `cat $1` )
	quantum=$2
	indexNumb="${#array[*]}"
	#c style for loop
	for ((i=0,j=1,k=2;i<$indexNumb;i=$i+3,j=$j+3,k=$k+3))
	do
		processArray+=( ${array[$i]} )
		arrivalTimeArray+=( ${array[$j]} )
		burstTimeArray+=( ${array[$k]} )
	done

	echo "   ${processArray[*]}"
#	****
	echo "   ${processArray[*]}" > output.txt
#	echo "  ${arrivalTimeArray[*]}"
#	echo "  ${burstTimeArray[*]}"
#################################
#
#Creating one more array queue were the processes will be stored/creating a variable that contains the total number of processes
#creating the time variable that starts from 0
#creating an empty string variable which will be updated with the processes that is in the top of the queue and running
	queue=()
	totalProcesses="${#processArray[*]}"
	Time=0
	running=""
#################################
#
#The emulation of round robins behaviour starts with a While loop. The loop will run until the status of all processes is set to F/(later)an empty string status is been created to store the outputs 
	while true
	do
		#In script test number 3 i had to create the status variable empty and then update it with the status and the time that way we have the print of the Time in the display of the terminal
		Status=""
		Status="$Status $Time"
		returnToQueue=0

#################################
		#
		queue=( "${queue[@]:1}" )
		running="${queue[0]}"
		#An if statement with a condition that is checking if the queue array is empty do the following:
		if test "${#queue[*]}" -eq 0
		then
			#The program is looping through all the elements of ArrivalTime array and BurstTime array
			for ((i=0; i<$totalProcesses; i++))
			do
				#The program will check if the AT=Time/the running variable is empty/the value of BT is greater than 0
				if [ "${arrivalTimeArray[$i]}" -eq "$Time" ]  && [ -z "$running" ] && [ "${burstTimeArray[$i]}" -gt 0 ]
				then
					#the programme will set status value to R/update queue/update running/decrement burst time by quantum
					Status="$Status R"
					queue+=( ${processArray[$i]} )
					running="${processArray[$i]}"
					bt="${burstTimeArray[$i]}"
					burstTimeArray[$i]=$(($bt-$quantum))
#echo bla bla
					#the programme will have to return the process at the back of the queue if the BT!=0
					if test "${burstTimeArray[$i]}" -gt 0
					then
						#*to return the process back to the queue we have to store it in a return variable - the idea came from the implementation of the design later on the code
						returnVariable="${processArray[$i]}"
					fi
				#The programm will do the following if there is more than one processes with AT=T but there is already one that is running
				elif [ "${arrivalTimeArray[$i]}" -eq "$Time" ] && [ ! -z "$running" ] && [ "${burstTimeArray[$i]}" -gt 0 ]
				then
					#Set status to W and store the process in the queue 
					Status="$Status W"
					queue+=( ${processArray[$i]} )
#echo bla bla
				#if the above conditions are not met for a process then the status will be set to -
				elif [ "${arrivalTimeArray[$i]}" -gt "$Time" ]
				then
					Status="$Status -"
#echo bla bla
				#if BT is =0 then the job is finished
				elif [ "${burstTimeArray[$i]}" -eq 0 ]
				then
					Status="$Status F"
#echo bla bla 
				fi
			done
			# *the return variable must be stored again at the back of the queue by updating the queue
			queue+=( $returnVariable )

##############################################################################################################################################################################

		#the else part of the main if statement now the programme will do the following were the condition is for a queue array that is not empty
		else
			#the programme is looping through all the elements of the arrays/this helps to manipulate the process in the queue that is R/W/-/F 
			for (( j=0; j<$totalProcesses; j++ ))
			do
				#a variable with value 0 is created to help the programme emulate which processes are in the queue if we have a match 0 becomes 1
				presentProcessQueue=0
				#a new for loop that helps the programme go through the array queue and check if there is a match 
				for (( k=0; k<${#queue[*]}; k++ ))
				do
					#the programme checks with the condition if a process is in the queue
					if test "${processArray[$j]}" == "${queue[$k]}"
					then
						#if match update the present process variable to 1
						presentProcessQueue=1

					fi
				done
				#the programme will now act if the process is in the queue will start the updates
				if test $presentProcessQueue -eq 1
				then
					#if the process is present in the queue, the programme will first have to check with conditions if process is Running and BT is greater than 0
					if [ "${processArray[$j]}" == "$running" ] && [ "${burstTimeArray[$j]}" -gt 0 ]
					then
						Status="$Status R"
						bt2="${burstTimeArray[$j]}"
						burstTimeArray[$j]=$(("$bt2"-"$quantum"))
						#the programme will store back to the queue the process that has BT not equal to 0
						if test "${burstTimeArray[$j]}" -gt 0
						then
							#a variable that stores the process with bt!=0 that will, this will help with the emulation of return to the queue process
							returnVariable2="${processArray[$j]}"
							#the programme needs a return to queue variable in order to meet the  condition in the proper timeline and store the value back to the queue
							returnToQueue=1
						fi
					#the else if part of the emulation of the behaviour of round robin will be for processes that are present in the queue but not running
					elif [ "${processArray[$j]}" != "$running" ] && [ "${burstTimeArray[$j]}" -gt 0 ]
					then
						Status="$Status W"
					#else if again to check if process is running but BT=0
					elif [ "${processArray[$j]}" == "$running" ] && [ "${burstTimeArray[$j]}" -eq 0 ]
					then
						Status="$Status F"
					fi
				#in this else part the programme checks if there is a process that has AT=Time but is not running and has BT greater than 0
				#or there is a process that has At<T and not running and BT=0
				#or or process has AT>T and BT>0 set status to -
				else
					if [ "${arrivalTimeArray[$j]}" -eq "$Time" ] && [ "${processArray[$j]}" != "$running" ] && [ "${burstTimeArray[$j]}" -gt 0 ]
					then
						Status="$Status W"
						queue+=( ${processArray[$j]} )
					elif [ "${arrivalTimeArray[$j]}" -lt "$Time" ] && [ "${processArray[$j]}" != "$running" ] && [ "${burstTimeArray[$j]}" -eq 0 ]
					then
						Status="$Status F"
					elif [ "${arrivalTimeArray[$j]}" -gt "$Time" ] && [ "${burstTimeArray[$j]}" -gt 0 ]
					then
						Status="$Status -"
					fi
				fi
			done

			if test $returnToQueue -eq 1 
			then
				queue+=( $returnVariable2 )
			fi
		fi
#################################
#
#For testing purposes
#echo "In queue" "${queue[*]}"
#echo "Running ->" "$running"
#echo "${queue[$k]}"
#with the following echo the programm displays in the terminal the output of the program and copying the output to a datafile.txt *** check at the beginning to understand the solution
#by solution means how every new display is being redirecting to that file and deleting the previous data
#The standard output will be copied to a file and still be visible to the terminal/even if the file exists this will appended under the headers / th headers come first and > this will overwritten the data of the existing file 
#and open the road to the new data ****
#echo "$Status"
echo "$Status" |& tee -a  output.txt
#echo "   ${processArray[*]}" > output.txt
#echo "$Status" >> output.txt
################################
#
#The update+ incrementation of Time plus the quantum
	((Time=$Time+$quantum))
###############################
#
#The break of loop for testing purposes
Number=`echo "$Status" | grep "F" -o | wc -l`
#echo $Number
		if test "${#processArray[*]}" -eq "$Number"
		then
			break
		fi
	done
fi
