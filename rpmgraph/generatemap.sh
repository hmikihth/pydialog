#!/bin/sh

#*********************************************************************************************************
#*   __     __               __     ______                __   __                      _______ _______   *
#*  |  |--.|  |.---.-..----.|  |--.|   __ \.---.-..-----.|  |_|  |--..-----..----.    |       |     __|  *
#*  |  _  ||  ||  _  ||  __||    < |    __/|  _  ||     ||   _|     ||  -__||   _|    |   -   |__     |  *
#*  |_____||__||___._||____||__|__||___|   |___._||__|__||____|__|__||_____||__|      |_______|_______|  *
#* http://www.blackpantheros.eu | http://www.blackpanther.hu - kbarcza[]blackpanther.hu * Charles Barcza *
#*************************************************************************************(c)2002-2016********

# Different style:
# landscape format

name=$1
format=$2
name2=$3
landscape=1
redline=0

if [ "$format" != "png" ]&&[ "$format" != "svg" ];then
 # print help if not entered format
 name=""
fi

if [ "x$name" = "x" ];then
  echo "
  Missing paramter as rpm name. Run script with parameter ! 
     Example: $basename $0 install  (for install dependency)
  And for generate RPM-Map

Description: | generator name|appliaction|map format |map name |
    Example: $basename $0 gimp svg
  OR
    Example: $basename $0 full /for full system mapping/
  OR 
    Example: $basename $0 gimp svg Different_SCREENSHOTNAME
"
  exit

fi

if [ "$name" = "install" ];then
  installing graphviz rpmorphan
  echo "
  Okay! 
  Now run script simple! Example: $basename $0 gimp
  "
  exit
fi


[ "x$name" = "x" ]&&echo "Missing packname! Example: $basename $0 gimp" && exit

gendot () {
echo "Run: rpmdep -dot $name.dot $name"
rpmdep -dot $name.dot $name 2>/dev/null
ret=$?
[ "$ret" = "1" ]&& echo "ERROR 1" && exit
[ ! -n "$name" ]&& echo "ERROR 2" && exit
[ ! -n "$name2" ]&& name2=$name
}

systemmap () {
name=Out
rpm --queryformat '%{NAME} \n' -qa | sort > pack_names.tmp 
cat pack_names.tmp | while read FILE; do $basename $0 $FILE 2>/dev/null ; done
}

gensysmap () {
awk '{if (!a[$0]++) print}' *.dot > ${name}.tmp
mv -f ${name}.tmp ${name}.dot

#perl -pi -e 's|;| [color=red,penwidth=1.0];|' ${name}.dot
perl -pi -e 's|;| minlen=30; splines=line; overlap = false; rankdir=LR ; nodesep=0.1; margin=0;|' ${name}.dot

genpng
rm -rf *.tmp
rm -rf *.dot
}
coloring () {
echo "Run: Coloring $name.dot"
# Red line
if [ "$redline" = "1" ];then
perl -pi -e 's|;| [color=red,penwidth=1.0];|' $name.dot
fi
# Gren conainer
if [ "$landscape" != "1" ];then
perl -pi -e 's|digraph "rpmdep" {|digraph "rpmdep" {
node [width = 0.95, fixedsize = false, style = filled, fillcolor = palegreen];|g' $name.dot
else
perl -pi -e 's|digraph "rpmdep" {|digraph "rpmdep" {
minlen=30; splines=line; overlap = false; rankdir=LR ; nodesep=0.1; margin=0;
node [fontname=Helvetica; fontsize=9; height=0.1; color=lightgray; style=filled; shape=record];|g' $name.dot
fi
genpng
}

genpng () {
if [ "$format" = "svg" ];then
    echo "Run: dot -Tsvg $name.dot -o $name2.svg"
    dot -Tsvg $name.dot -o $name2.svg 2>/dev/null
elif [ $format = png ];then
    echo "Run: dot -Tpng $name.dot -o $name2.png"
    dot -Tpng $name.dot -o $name2.png 2>/dev/null
else
    echo "first package name: $1 Second: $2 Third ADD: svg or png forma ?????"
fi
}

if [ "$name" = "full" ];then
echo "Generating full system MAP"
    systemmap
    gensysmap
    exit

fi

gendot
coloring

#finish
