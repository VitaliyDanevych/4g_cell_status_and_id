#! /bin/sh

wdir=/home/fmuser2/scripts/4g_status
cd ${wdir}/

echo "getting new RN_* databases..."
/opt/ericsson/ddc/util/bin/listme | grep RN_ | sed -e 's/[@=,]/ /g' | awk '{print $6}' | sort | uniq > ${wdir}/list_erbs.txt

rm ${wdir}/4g_cell_status.txt
#Added site_id request - ;lget . eNBid;
/opt/ericsson/bin/amosbatch -p 30 -t 3 ${wdir}/list_erbs.txt "lt all;s+;prox;l+ ${wdir}/4g_cell_status.txt;st cell;lget . eNBid;l-;q" ${wdir}/log
#/opt/ericsson/bin/amosbatch -p 30 -t 3 ${wdir}/list_erbs.txt "lt all;s+;prox;l+ ${wdir}/4g_cell_status.txt;st cell;l-;q" ${wdir}/log

# Status 4G sites are located below
rm ${wdir}/4g_cell_status_parsed.txt
echo 'AdmState;Op.State;MO' > ${wdir}/4g_cell_status_parsed.txt
cat ${wdir}/4g_cell_status.txt | grep EUtranCellFDD | egrep -v 'password|uservariable' | awk '{print $6";"$3";"$5}' | sed -e 's/(//g' | sed -e 's/)//g' | sed -e 's/ENodeBFunction=1,EUtranCellFDD=//g' | dos2unix >> ${wdir}/4g_cell_status_parsed.txt
perl -pi -e 's/SHUTTINGDOWN/LOCKED/g' ${wdir}/4g_cell_status_parsed.txt
cp -p ${wdir}/4g_cell_status_parsed.txt ${wdir}/data/4g_cell_status_parsed_$(date '+DATE: %d_%m_%Y_%H_%M' | sed 's/DATE: //').txt

# Site_ID 4G sites are located below
rm ${wdir}/4g_cell_status_parsed_enodeb_id.txt
echo 'SITE;SITE_ID' > ${wdir}/4g_cell_status_parsed_enodeb_id.txt
cat ${wdir}/4g_cell_status.txt | grep -v ERBS_ | egrep '1 ENodeBFunction|lget . eNBid' | gsed -r -e 's/^(RN_.+?)>.*$/\1 /g' | gsed -r 's/^.+?ENodeBFunction.+?eNBId\s+(\w+).*$/\1 /g' | gsed -e 's/\n/;/g' | perl -pi -e 's/\n/\;/g;' | perl -pi -e 's/\;RN_/\nRN_/g;' | sed 's/ //g' | cut -c -16 >> ${wdir}/4g_cell_status_parsed_enodeb_id.txt
cp -p ${wdir}/4g_cell_status_parsed_enodeb_id.txt ${wdir}/data/4g_cell_status_parsed_enodeb_id_$(date '+DATE: %d_%m_%Y_%H_%M' | sed 's/DATE: //').txt

#java -classpath /home/fmuser2/scripts/EricssonToOptima/ToOracle_ftpParserV7.jar ToOracle_fileLoad -path=/home/fmuser2/scripts/4g_status/4g_cell_status_parsed.txt -TblName=configuration.e_4g_status -TruncateTable
# Insert status 4G sites below
java -classpath /home/fmuser2/scripts/EricssonToOptima/ToOracle_ftpParserV7.jar ToOracle_fileLoad -path=/home/fmuser2/scripts/4g_status/4g_cell_status_parsed.txt -TblName=configuration.e_4g_status

# Insert SITE_ID data below
java -classpath /home/fmuser2/scripts/EricssonToOptima/ToOracle_ftpParserV7.jar ToOracle_fileLoad -path=/home/fmuser2/scripts/4g_status/4g_cell_status_parsed_enodeb_id.txt -TblName=configuration.e_4g_site_id

find ${wdir}/log -name "*.log" -mtime +5 -exec rm '{}' \;
find ${wdir}/data -name "*.txt" -mtime +10 -exec rm '{}' \;
