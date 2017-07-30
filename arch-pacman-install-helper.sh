# Make sure that you use quotes when reading these variables to preserve newlines.

# creates pacman friendly args from here doc variable
var_to_pacman(){
    echo "$1" | cut -d# -f1 | paste -sd " " | tr -s [:space:] | tr -d '\t'
}

read_sect_from_file(){
    # We ask first for the section delimiters. $1_START and $2_END.
    # We also need the file from which to read this. $2
    SECT_START="$1"_START
    SECT_END="$1"_END
    FILENAME=$2
    sed -n "/$SECT_START/,/$SECT_END/p" $FILENAME | sed -e "/$SECT_START/d" -e "/$SECT_END/d"
}

if [ "$#" -lt 1 ] || [ "$1" == "-" ]; then
    FILENAME="installable-package-list.txt"
    echo "::::-- Using default file 'installable-package-list.txt' --::::"
else
    FILENAME=$1
fi

echo "Available sections in $FILENAME:"
grep "^APIH.*START$" "$FILENAME" | sed -e 's/_START//g'
echo

if [ "$#" -eq 2 ]; then
    SECT_NAME=$2
else
    SECT_NAME="APIH_XORG_RELATED"
    echo "::::-- Using default section APIH_XORG_RELATED --::::"
fi

echo "Reading section $SECT_NAME from '$FILENAME'"
SECTION=`read_sect_from_file "$SECT_NAME" "$FILENAME"`
echo "$SECTION" | grep -v ^#
echo

echo "::::-- Cleaning up section --::::"
CLEAN_SECTION=`var_to_pacman "$SECTION"`
echo $CLEAN_SECTION
echo

echo "The above packages have been selected for installation."
echo "Modify relevant section in the input file to change selection."
echo "pacman command to be used: 'sudo pacman -Sy --needed PKG-LIST'."
echo "Edit this script in case you wish to change the command used."
echo "---------------"

read -p "Continue to install with 'sudo pacman -Sy --needed PKG-LIST'  (y/N)?" choice
case "$choice" in 
  y|Y ) sudo pacman -Sy --needed $CLEAN_SECTION;;
  n|N ) echo "exiting...";;
  * ) echo "Default behaviour: exiting...";;
esac
