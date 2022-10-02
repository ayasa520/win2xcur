#!/bin/bash

has_command() {
  "$1" -v $1 > /dev/null 2>&1
}

function create {
	cd "$SRC"
	mkdir -p x1 x1_25 x1_5 x2

	cd "$SRC"/$1
	find . -name "*.png" -type f -exec sh -c 'inkscape -o "../x1/${0%}" -w 32 -h 32 $0' {} \;
	find . -name "*.png" -type f -exec sh -c 'inkscape -o "../x1_25/${0%}" -w 40 -w 40 $0' {} \;
	find . -name "*.png" -type f -exec sh -c 'inkscape -o "../x1_5/${0%}" -w 48 -w 48 $0' {} \;
	find . -name "*.png" -type f -exec sh -c 'inkscape -o "../x2/${0%}" -w 64 -w 64 $0' {} \;

	cd "$SRC"

	OUTPUT="$BUILD"/cursors
	ALIASES="$SRC"/cursorList

	if [ ! -d "$BUILD" ]; then
		mkdir "$BUILD"
	fi
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
	done < "$ALIASES"
	echo -e "Generating shortcuts... DONE"

	cd "$PWD"

	echo -ne "Generating Theme Index...\\r"
	INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX"
	fi
	echo -e "Generating Theme Index... DONE"
}

echo "是否使用已有的配置文件? 如果是, 将已有配置文件放入 config 目录"
select old_config in 是 否;
do
    break
done

if [ ! "$(which xcursorgen 2> /dev/null)" ]; then
  echo xorg-xcursorgen needs to be installed to generate the cursors.
  if has_command zypper; then
    sudo zypper in xorg-xcursorgen
  elif has_command apt; then
    sudo apt install xorg-xcursorgen
  elif has_command dnf; then
    sudo dnf install -y xorg-xcursorgen
  elif has_command dnf; then
    sudo dnf install xorg-xcursorgen
  elif has_command pacman; then
    sudo pacman -S --noconfirm xorg-xcursorgen
  fi
fi

if [ ! "$(which inkscape 2> /dev/null)" ]; then
  echo inkscape needs to be installed to generate the cursors.
  if has_command zypper; then
    sudo zypper in inkscape
  elif has_command apt; then
    sudo apt install inkscape
  elif has_command dnf; then
    sudo dnf install -y inkscape
  elif has_command dnf; then
    sudo dnf install inkscape
  elif has_command pacman; then
    sudo pacman -S --noconfirm inkscape
  fi
fi

if [ ! "$(which win2xcur 2> /dev/null)" ]; then
  echo xcursorgen needs to be installed to generate the cursors.
  pip install win2xcur
fi

SRC=$PWD/src
BUILD="$SRC/../dist"

mkdir -p $SRC/output $SRC/config

cd $SRC/wincusors

INSTALL_INF=$(find -name "*.inf")
declare -A CURS

CURS=([help]="help" [work]="progress" [busy]="wait" [cross]="crosshair" [text]="text" [handwrt]="pencil" [unavailable]="circle" [vert]="size_ver" [horz]="size_hor" [dgn1]="size_fdiag" [dgn2]="size_bdiag" [move]="fleur" [pointer]="default" [link]="pointer")

THEME=$(grep 'SCHEME_NAME' *.inf | tail -n 1 | cut -f2 -d"=" | sed -e's/"//g' -e 's/^\s*//g'   -e 's/\s*$//g')" Cursors"
sed -i "s/\r//g" *.inf

for key in ${!CURS[@]}
do
    name=$(grep "^${key}" *.inf | tail -n 1 | cut -f2 -d'=' | sed -e "s/\s*\([A-Za-z0-9 ]*\)\.ani/\1.ani/" -e 's/\"//g' -e 's/^\s*//g'   -e 's/\s*$//g')
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

if [ $old_config = "y" ];then
    cd $SRC/output
    mkdir -p $SRC/png

    XCURS=$(ls)

    for xcur in ${XCURS}
    do
        xcur2png -d ../png ${xcur}
    done

    # config 目前得自己写, 也许 ani 文件中有信息, 但我暂时看不懂
    rm *.conf 
    # generate pixmaps from svg source

    create png


    cd "$SRC"
    rm -rf x1 x1_25 x1_5 x2 output
else
    OUTPUT="$BUILD"/cursors
    mkdir -p $OUTPUT
    mv $SRC/output/* $OUTPUT

    INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX"
	fi
    cd $OUTPUT
    ln -s progress 00000000000000020006000e7e9ffc3f 
    ln -s size_ver 00008160000006810000408080010102 
    ln -s circle 03b6e0fcb3499374a867c041f52298f0 
    ln -s progress 08e8e1c95fe2fc01f976f1e063a24ccd 
    ln -s progress 3ecb610c1bf2410f44200f48c40d3599 
    ln -s help 5c6cd98b3f3ebcb1f9c7f1c204630408 
    ln -s copy 6407b0e94181790501fd1e167b474872 
    ln -s alias 640fb0e74195791501fd1ed57b41487f 
    ln -s pointer 9d800788f1b08800ae810202380a0822 
    ln -s help d9ce0ab605698f320427677b458ad60b 
    ln -s pointer e29285e634086352946a0e7090d73106 
    ln -s fleur all-scroll
    ln -s default arrow 
    ln -s size_bdiag bottom_left_corner 
    ln -s size_fdiag bottom_right_corner 
    ln -s size_ver bottom_side 
    ln -s size_hor col-resize
    ln -s crosshair cross 
    ln -s size_hor e-resize 
    ln -s progress half-busy
    ln -s size_hor h_double_arrow 
    ln -s default left_ptr 
    ln -s progress left_ptr_watch 
    ln -s size_hor left_side 
    ln -s bottom_left_corner ll_angle 
    ln -s bottom_right_corner lr_angle 
    ln -s top_right_corner ne-resize
    ln -s size_ver n-resize
    ln -s top_left_corner nw-resize 
    ln -s help question_arrow 
    ln -s size_hor right_side 
    ln -s size_ver row-resize 
    ln -s size_hor sb_h_double_arrow 
    ln -s size_ver sb_v_double_arrow 
    ln -s bottom_right_corner se-resize 
    ln -s fleur size_all 
    ln -s col-resize split_h 
    ln -s row-resize split_v 
    ln -s size_ver s-resize 
    ln -s bottom_left_corner sw-resize
    ln -s size_fdiag top_left_corner 
    ln -s size_bdiag top_right_corner 
    ln -s size_ver top_side 
    ln -s top_left_corner ul_angle 
    ln -s top_right_corner ur_angle 
    ln -s wait watch 
    ln -s help whats_this 
    ln -s size_hor w-resize
fi

