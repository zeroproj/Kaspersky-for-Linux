#!/bin/bash
clear
echo "####################################################"
echo "# INSTALAÇÃO PROTEÇÃO KASPERSKY ENDPOINT FOR LINUX #"
echo "###########OS: Debian/Ubuntu/CentOS Server##########"
echo "########################################## MH_V1.0##"
ver="MH_V1.0"
#DEFINIR PARAMETROS
klna=/opt/kaspersky/klnagent/bin/
kes=/opt/kaspersky/kesl/bin/
dic_temp=/tmp/kaslinux/
link_kla_deb="agent_deb"
link_kla_rpm="agent_rpm"
link_kes_deb=https://products.s.kaspersky-labs.com/endpoints/keslinux10/11.1.0.3013/multilanguage-INT-11.1.0.3013/3330333430317c44454c7c31/kesl_11.1.0-3013_amd64.deb
link_kes_rpm=https://products.s.kaspersky-labs.com/endpoints/keslinux10/11.1.0.3013/multilanguage-INT-11.1.0.3013/3331353036317c44454c7c31/kesl-11.1.0-3013.x86_64.rpm
#Paramentros de Instalação Kaspersky Endpoint
EULA_AGREED=yes
PRIVACY_POLICY_AGREED=yes
USE_KSN=yes
UPDATER_SOURCE=SCServer
UPDATE_EXECUTE=yes
USE_GUI=no
USER=
IMPORT_SETTINGS=no

#Arquivos temporarios
echo
if [ ! -d $dic_temp ]
then
mkdir -m 755 -p $dic_temp
echo " * Realizando criação do diretorio temporario"
else
echo " * Realizando Limpeza de arquivos temporarios"
rm $dic_temp/* -rf
fi

#Removendo aplicaçoes Kaspersky
if [ -f /usr/bin/dpkg ]
    then pkg="deb"
    if [ -d $klna ]
    then
    echo " * Realizando remoção de versoes anteriores do Kaspersky Agente"
    dpkg -r klnagent >> $dic_temp/rem_kla.log
    fi
    if [ -d $kes ]
    then
    echo " * Realizando remoção de versoes anteriores do Kaspersky Endpoint"
    dpkg -r kesl >> $dic_temp/rem_kes.log
    fi
elif [ -f /usr/bin/rpm ]
    then pkg="rpm"
    if [ -d $klna ]
    then
    echo " * Realizando remoção de versoes anteriores do Kaspersky Agente"
    rpm -e klnagent >> $dic_temp/rem_kla.log
    fi
    if [ -d $kes ]
    then
    echo " * Realizando remoção de versoes anteriores do Kaspersky Endpoint"
    rpm -e kesl >> $dic_temp/rem_kes.log
    fi
fi

echo
echo "####################################################"
echo "#############INSTALAÇÃO AGENTE KASPERSKY############"
echo "####################################################"

if [ -f /usr/bin/dpkg ]
    then pkg="deb"
    echo " * Instalação de dependecias necessarias"
    sudo apt install -y perl libc6 libc6-dev libc6-i386 libc6-dev-i386 gcc binutils make rpcbind >> $dic_temp'inst_klnagent.log'
    echo " * Download do Agente de Rede"
    wget -q -c -O $dic_temp'KLA.sh' -P $dic_temp $link_kla_deb 
    echo " * Instalando Kaspersky Agente de Rede"
    bash $dic_temp/KLA.sh >> $dic_temp/inst_klnagent.log
elif [ -f /usr/bin/rpm ]
    then pkg="rpm"
    echo " * Instalação de dependecias necessarias"
    yum install -y perl wget gcc glibc glibc-devel glibc.i686 make rpcbind binutils >> $dic_temp'inst_klnagent.log'
    echo " * Download do Agente de Rede"
    wget -q -c -O $dic_temp'KLA.sh' -P $dic_temp $link_kla_rpm 
    echo " * Instalando Kaspersky Agente de Rede"
    bash $dic_temp/KLA.sh >> $dic_temp/inst_klnagent.log
fi
echo " * Instalação do Kaspersky Agente de Rede completa"
echo
echo "####################################################"
echo "############INSTALAÇÃO KASPERSKY ENDPOINT###########"
echo "####################################################"

if [ -f /usr/bin/dpkg ]
    then pkg="deb"
    echo " * Download do Kaspersky Endpoint"
    wget -q -c -O $dic_temp'KES.deb' -P $dic_temp $link_kes_deb
    echo " * Instalando Kaspersky Endpoint"
    dpkg -i $dic_temp'KES.deb' >> $dic_temp/inst_kesl.log

elif [ -f /usr/bin/rpm ]
    then pkg="rpm"
    echo " * Download do Kaspersky Endpoint"
    wget -q -c -O $dic_temp'KES.rpm' -P $dic_temp $link_kes_rpm 
    echo " * Instalando Kaspersky Endpoint"
    rpm -ivh $dic_temp'KES.rpm' >> $dic_temp/inst_kesl.log
fi
echo " * Instação do Kaspersky Endpoint completa"
echo " * Gerando arquivo de configuração"
touch $dic_temp'kesl_autoanswers.conf'
echo -e "EULA_AGREED='$EULA_AGREED'\nPRIVACY_POLICY_AGREED=$PRIVACY_POLICY_AGREED\nUSE_KSN=$USE_KSN\nUPDATER_SOURCE=$UPDATER_SOURCE\nUPDATE_EXECUTE=$UPDATE_EXECUTE\nUSE_GUI=$USE_GUI\nIMPORT_SETTINGS=$IMPORT_SETTINGS\nADMIN_USER_IF_USE_GUI=$USER" >> $dic_temp'kesl_autoanswers.conf'
echo " * Configurando Kaspersky Endpoint"
/opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=$dic_temp'kesl_autoanswers.conf'
echo " * Configurando Concluida"
echo " * Instalação finalizada"
#Desenvolvido por ZEROPROJ
