FULLNAME=$1
TTF2PT1=`which ttf2pt1`
DATE=`date`
TEXMF=~/.texmf-var

if [ $# -eq 3 ]
then
  FNAME=`basename $FULLNAME`
  eval `echo $FNAME | awk -F. '{printf "FHEAD=%s;FTAIL=%s",\$1,\$2}'`
  FHEAD=$2
  FONTNAME=$3
else
  echo "Usage: `basename $0` your.ttf subfont_name font_name"
  exit
fi


check_enc()
{
    NUMLIST=`awk 'BEGIN{ n=0; while(n<256){printf "%02x\n",n; n++}}'`
    MAP=unicode-sample.map
    UTF8ENC=70
    GBKENC=19
    UTF8FD=${TEXMF}/tex/latex/CJK/UTF8
    GBKFD=${TEXMF}/tex/latex/CJK/GBK
}

create_type1()
{
  echo "Now create *.pfb and *.enc files, wait... "
  for i in $NUMLIST
  do
    ttf2pt1 -GAE -pttf -OHUBs -W0 -l plane+pid=3,eid=1,0x$i $FULLNAME ${FHEAD}$i
  done

# avoid dvips t1part module bugs.
  perl -pi -e 's/_/Z/g' *.t1a *.afm

  for ps in *.t1a
  do
    t1asm -b $ps > ${ps%.t1a}.pfb
  done
}

create_map()
{
MAPFILE=t1-${FHEAD}.map
ENCMAP=ttf-${FHEAD}.map
  echo "Create *.tfm and (dvips)map file, wait..."
  cat > $MAPFILE << EndOfFile
% This is map file for dvips/dvipdfm[x] and LaTeX CJK package.
% Created by Edward G.J. Lee <edt1023@info.sayya.org>
% $DATE
EndOfFile
  cat > $ENCMAP << EndOfFile
% This is map file for PDFLaTeX and LaTeX CJK package to embed TTF.
% Created by Edward G.J. Lee <edt1023@info.sayya.org>
% $DATE
EndOfFile
  for i in $NUMLIST
  do
    PSNAME=`awk '/FontName/ {print $2}' ${FHEAD}$i.afm`
    afm2tfm ${FHEAD}$i.afm > /dev/null 2>&1
    cat >> $MAPFILE << EndOfFile
${FHEAD}$i $PSNAME <${FHEAD}$i.pfb
EndOfFile
    cat >> $ENCMAP << EndOfFile
${FHEAD}$i <${FHEAD}$i.enc <${FNAME}
EndOfFile
  done
}

create_cidmap()
{
cat >> cid-x.map << EndOfFile
gbk$FHEAD@UGBK@ UniGB-UCS2-H :0:$FNAME
$FHEAD@Unicode@ unicode :0:$FNAME
EndOfFile
}

create_cjkfd()
{
cat > c${UTF8ENC}${FONTNAME}.fd << EndOfFile
\ProvidesFile{c${UTF8ENC}${FONTNAME}.fd}[\filedate\space\fileversion]
\DeclareFontFamily{C${UTF8ENC}}{$FONTNAME}{\hyphenchar \font\m@ne}
\DeclareFontShape{C${UTF8ENC}}{$FONTNAME}{m}{n}{<-> CJK * $FHEAD}{}
\DeclareFontShape{C${UTF8ENC}}{$FONTNAME}{bx}{n}{<-> CJKb * $FHEAD}{\CJKbold}
\endinput
EndOfFile

cat > c${GBKENC}${FONTNAME}.fd << EndOfFile
\ProvidesFile{c${GBKENC}${FONTNAME}.fd}[\filedate\space\fileversion]
\DeclareFontFamily{C${GBKENC}}{$FONTNAME}{\hyphenchar \font\m@ne}
\DeclareFontShape{C${GBKENC}}{$FONTNAME}{m}{n}{<-> CJK * gbk$FHEAD}{}
\DeclareFontShape{C${GBKENC}}{$FONTNAME}{bx}{n}{<-> CJKb * gbk$FHEAD}{\CJKbold}
\endinput
EndOfFile
}

create_vf()
{
  echo "Create virtual fonts file, wait..."
perl uni2sfd.pl $FHEAD UGBK.sfd gbk$FHEAD gbk
}

# main()
check_enc
create_type1
create_map
create_cidmap
create_cjkfd
create_vf

AFM=${TEXMF}/fonts/afm/$FHEAD
TFM=${TEXMF}/fonts/tfm/$FHEAD
PFB=${TEXMF}/fonts/type1/$FHEAD
ENC=${TEXMF}/fonts/enc/$FHEAD
VF=${TEXMF}/fonts/vf/$FHEAD
TTF=${TEXMF}/fonts/truetype/$FHEAD
MAPDIR=${TEXMF}/fonts/map
rm -f *.t1a
mkdir -p $AFM $TFM $PFB $ENC $VF $TTF
mv -f *.enc $ENC
mv -f *.afm $AFM
mv -f *.tfm $TFM
mv -f *.pfb $PFB
mv -f *.vf $VF
mv -f $FNAME $TTF
mkdir -p $MAPDIR/dvips
mkdir -p $MAPDIR/pdftex
mkdir -p $MAPDIR/dvipdfm
mv -f $MAPFILE $MAPDIR/dvips
mv -f $ENCMAP $MAPDIR/pdftex
cat  cid-x.map >> $MAPDIR/dvipdfm/cid-x.map
rm cid-x.map
mkdir -p $UTF8FD $GBKFD
mv -f c${UTF8ENC}${FONTNAME}.fd $UTF8FD
mv -f c${GBKENC}${FONTNAME}.fd $GBKFD

echo "Running texhash and updmap, pls wait"
texhash >/dev/null 2>&1
updmap --enable Map=ttf-${FHEAD}.map >/dev/null 2>&1

echo "Congradulations! you have added ${FHEAD} into your texmf"
