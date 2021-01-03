#!/bin/bash
cd `dirname ${BASH_SOURCE}`
name=$(basename $BASH_SOURCE)
command="bash tor-exit-monitor"
function doStart {
	pid=`pidof $name`
	if [ ! $pid ] ; then
		rm -f $name.out $name.err
		bash -c "exec -a $name $command &" 1>>$name.out 2>>$name.err
		sleep 1
	fi
	pid=`pidof $name`
	if [ $pid ] ; then
		echo $pid started
	else
		cat $name.err
	fi
}
function doStop {
	pid=`pidof $name`
	if [ $pid ] ; then
		echo $pid stopped
		kill $pid
		sleep 1
	fi
}
trap 'onCtrlC' INT
function onCtrlC {
	doStop
}
if [ "$1" == "stop" ] ; then
	doStop
	exit
elif [ "$1" == "start" ] ; then
	doStart
	exit
elif [ "$1" == "restart" ] ; then
	doStop
	doStart
	exit
else
	doStart
	pid=`pidof $name`
	if [ $pid ] ; then
		tail --pid=$pid -qf $name.out $name.err
	fi
fi
