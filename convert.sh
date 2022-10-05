#!/bin/bash

has_command() {
	"$1" -v $1 >/dev/null 2>&1
}

function create {
	cd "$SRC"
	mkdir -p x1 x1_25 x1_5 x2

	tmp_fifofile="/tmp/$$.fifo"
	mkfifo $tmp_fifofile  # 新建一个FIFO类型的文件
	exec 6<>$tmp_fifofile # 将FD6指向FIFO类型
	rm $tmp_fifofile      #删也可以，

	thread_num=5 # max thread count
	for ((i = 0; i < ${thread_num}; i++)); do
		echo
	done >&6

	cd "$SRC"/$1

	cat /dev/null >inkscape.log

	pngs=$(ls *.png)

    mark=''
    count=0 
    all=$(ls -l *.png| wc -l)
    all=$((all*4))
	for factor in "${!SIZE_ARRAY[@]}"; do
		for png_file in ${pngs}; do
			read -u6
			{
				inkscape -o "../$factor/$png_file" -w "${SIZE_ARRAY[$factor]}" -h "${SIZE_ARRAY[$factor]}" $png_file 2>inkscape.log
				echo >&6
			} &
            count=$((count+1))
            printf "progress: %s\r" "$((count*100/all))%"
		done
	done 
    wait
    echo 

	cd "$SRC"

	OUTPUT="$BUILD"/cursors
	ALIASES="$SRC"/cursorList
    if [ -d "$BUILD" ]; then
        rm -rf "$BUILD"
    fi
    
    mkdir "$BUILD"
        
	if [ ! -d "$OUTPUT" ]; then
		mkdir "$OUTPUT"
	fi

	echo -ne "Generating cursor theme...\\r"
	for CUR in config/*.cursor; do
		BASENAME="$CUR"
		BASENAME="${BASENAME##*/}"
		BASENAME="${BASENAME%.*}"

		xcursorgen "$CUR" "$OUTPUT/$BASENAME"
	done
	echo -e "Generating cursor theme... DONE"

	cd "$OUTPUT"

	#generate aliases
	echo -ne "Generating shortcuts...\\r"
	while read ALIAS; do
		FROM="${ALIAS#* }"
		TO="${ALIAS% *}"

		if [ -e $TO ]; then
			continue
		fi
		ln -sr "$FROM" "$TO"
	done <"$ALIASES"
	echo -e "Generating shortcuts... DONE"

	cd "$PWD"

	echo -ne "Generating Theme Index...\\r"
	INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" >"$INDEX"
	fi
	echo -e "Generating Theme Index... DONE"
}

function process_config {
	sed -i '/^#/d' "$1"
	content=$(cat "$1")
	cat /dev/null >"$1"

	for factor in "${!SIZE_ARRAY[@]}"; do
		echo "$content" | awk -v factor=$factor -v size=${SIZE_ARRAY[$factor]} '{match($4, "/([^/]+)\\.png$")} {$4=factor""substr($4, RSTART,RLENGTH)} {$2=$2*size/$1;$3=$3*size/$1;$1=size}{printf "%d\t%.0f\t%.0f\t%s\t%d\n",$1,$2,$3,$4,$5}' >>$1
	done

}

if [ ! "$(which xcursorgen 2>/dev/null)" ]; then
	echo xorg-xcursorgen needs to be installed to generate the cursors.
	if has_command zypper; then
		sudo zypper in xorg-xcursorgen
	elif has_command apt; then
		sudo apt install -y x11-apps
	elif has_command dnf; then
		sudo dnf install -y xorg-xcursorgen
	elif has_command dnf; then
		sudo dnf install xorg-xcursorgen
	elif has_command pacman; then
		sudo pacman -S --noconfirm xorg-xcursorgen
	fi
fi

if [ ! "$(which inkscape 2>/dev/null)" ]; then
	echo inkscape needs to be installed to generate the cursors.
	if has_command zypper; then
		sudo zypper in inkscape
	elif has_command apt; then
		sudo apt install -y inkscape
	elif has_command dnf; then
		sudo dnf install -y inkscape
	elif has_command dnf; then
		sudo dnf install inkscape
	elif has_command pacman; then
		sudo pacman -S --noconfirm inkscape
	fi
fi

if [ ! "$(which win2xcur 2>/dev/null)" ]; then
	echo win2xcur needs to be installed to generate the cursors.
	pip install win2xcur
fi

SRC=$PWD/src
BUILD="$SRC/../dist"
declare -A SIZE_ARRAY
SIZE_ARRAY=([x1]=24 [x1_25]=30 [x1_5]=36 [x2]=48)
mkdir -p "$SRC/output" "$SRC/config"

cd "$SRC/wincursors"

INSTALL_INF=$(ls *.inf)
if [[ $(file -i $INSTALL_INF) =~ "iso-8859-1" ]]; then 
    iconv -f gb18030 -t UTF-8 $INSTALL_INF -o $INSTALL_INF
fi 

declare -A CURS

CURS=([help]="help" [work]="progress" [busy]="wait" [cross]="crosshair" [text]="text" [handwrt]="pencil" [unavailable]="circle" [vert]="size_ver" [horz]="size_hor" [dgn1]="size_fdiag" [dgn2]="size_bdiag" [move]="fleur" [pointer]="default" [link]="pointer" [hand]="pencil")

THEME=$(grep 'SCHEME_NAME' *.inf | tail -n 1 | cut -f2 -d"=" | sed -e's/"//g' -e 's/^\s*//g' -e 's/\s*$//g')" Cursors"
# sed -i "s/\r//g" *.inf

for key in "${!CURS[@]}"; do
	name=$(grep -i "^${key}" *.inf | tail -n 1 | cut -f2 -d'=' | sed -e "s/\s*\([A-Za-z0-9 ]*\)\.ani/\1.ani/" -e 's/\"//g' -e 's/^\s*//g' -e 's/\s*$//g')
	echo "rename $name to ${CURS[${key}]}.ani"
	perl-rename "s/$name/${CURS[${key}]}.ani/" *.ani
done

ANIS=$(ls *.ani)

# for ani in ${ANIS[@]}
# do
#     # echo $SRC/wincusors/${ani}
#     # ../../ani2ico $SRC/wincusors/${ani}
#     # 暂时不研究, ani 看不懂. 这个直接转换过的尺寸只有 160px 一种, 所以只是借用来提取 png
# done

# 如果不自己写 config, 这步完了直接用就行了
# win2xcur ./*.{ani,cur} -o ../output/
win2xcur ./*.ani -o ../output/

cd "$SRC/output"
if [ -d "$SRC/png" ]; then
	rm -rf "$SRC/png"
fi
mkdir -p "$SRC/png"

XCURS=$(ls)

for xcur in ${XCURS}; do
	"$SRC"/xcur2png -d ../png ${xcur}
done


perl-rename 's/(.*).conf/$1.cursor/' *.conf
rm ../config/*
mv *.cursor ../config
# generate pixmaps from svg source
cd ../config
CONFS=$(ls *.cursor)

for CONF in ${CONFS}; do
	process_config ${CONF}
done

create png

cd "${SRC}"
rm -rf x1 x1_25 x1_5 x2 output
