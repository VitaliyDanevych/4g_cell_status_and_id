# 4g_cell_status_and_id
Gets data from each site, parce and load to DB

The key functionality.

Файл аутпута всех 4Г сайтов на команды АМОС - 4g_cell_status.txt,
После строк ниже:
echo 'AdmState;Op.State;MO' > ${wdir}/4g_cell_status_parsed.txt
cat ${wdir}/4g_cell_status.txt | grep EUtranCellFDD | egrep -v 'password|uservariable' | awk '{print $6";"$3";"$5}' | sed -e 's/(//g' | sed -e 's/)//g' | sed -e 's/ENodeBFunction=1,EUtranCellFDD=//g' | dos2unix >> ${wdir}/4g_cell_status_parsed.txt
perl -pi -e 's/SHUTTINGDOWN/LOCKED/g' ${wdir}/4g_cell_status_parsed.txt


Превращается в файл 4g_cell_status_parsed.txt,
его фрагмент ниже:
AdmState;Op.State;MO
CH0052L11;LOCKED;DISABLED
CH0052L21;LOCKED;DISABLED
CH0052L31;LOCKED;DISABLED
CH0044L11;LOCKED;DISABLED
CH0044L21;LOCKED;DISABLED

Файл аутпута всех 4Г сайтов на команды АМОС - 4g_cell_status.txt,
После строк ниже:
echo 'SITE;SITE_ID' > ${wdir}/4g_cell_status_parsed_enodeb_id.txt
cat ${wdir}/4g_cell_status.txt | grep -v ERBS_ | egrep '1 ENodeBFunction|lget . eNBid' | gsed -r -e 's/^(RN_.+?)>.*$/\1 /g' | gsed -r 's/^.+?ENodeBFunction.+?eNBId\s+(\w+).*$/\1 /g' | gsed -e 's/\n/;/g' | perl -pi -e 's/\n/\;/g;' | perl -pi -e 's/\;RN_/\nRN_/g;' | sed 's/ //g' | cut -c -16 >> ${wdir}/4g_cell_status_parsed_enodeb_id.txt

Превращается в файл 4g_cell_status_parsed_enodeb_id.txt,
его фрагмент ниже:
SITE;SITE_ID
RN_CH0052;950052
RN_CH0044;950044
RN_CH0036;950036
RN_CH0009;950009
RN_CH0041;950041
RN_CH0012;950012
