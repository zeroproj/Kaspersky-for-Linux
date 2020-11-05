#!/bin/bash
clear
echo "###########################################################################"
echo "################# INSTALAÇÃO PROTEÇÃO KASPERSKY ENDPOINT ##################"
echo "############## OS: Debian/Ubuntu/CentOS/Fedora/macOS Server ###############"
echo "############################################################### ZP_V6.0 ###"
#################################################
#***********************************************#
#Paramentros de Instalação Kaspersky Agente
#################################################
KLNAGENT_SERVER=IP.COM.BR
#################################################
KLNAGENT_PORT=14000
KLNAGENT_SSLPORT=13000
KLNAGENT_USESSL=y
KLNAGENT_GW_MODE=1
#Paramentros de Instalação Kaspersky Endpoint
#################################################
EULA_AGREED=yes
PRIVACY_POLICY_AGREED=yes
USE_KSN=yes
UPDATER_SOURCE=KLServers
UPDATE_EXECUTE=no
USE_GUI=yes
USER=
IMPORT_SETTINGS=no
#Produtos Kaspersky Link
#################################################
link_kla_deb="https://products.s.kaspersky-labs.com/endpoints/keslinux10/11.1.0.3013/multilanguage-INT-11.1.0.3013/3330333430367c44454c7c31/klnagent64_11.0.0-38_amd64.deb"
link_kla_rpm="https://products.s.kaspersky-labs.com/endpoints/keslinux10/11.1.0.3013/multilanguage-INT-11.1.0.3013/3330333430347c44454c7c31/klnagent64-11.0.0-38.x86_64.rpm"
link_kes_deb=https://products.s.kaspersky-labs.com/endpoints/keslinux10/11.1.0.3013/multilanguage-INT-11.1.0.3013/3330333430317c44454c7c31/kesl_11.1.0-3013_amd64.deb
link_kes_rpm=https://products.s.kaspersky-labs.com/endpoints/keslinux10/11.1.0.3013/multilanguage-INT-11.1.0.3013/3331353036317c44454c7c31/kesl-11.1.0-3013.x86_64.rpm
link_ag_mac=https://products.s.kaspersky-labs.com/workstations/kesmac10/12.0.0.35/multilanguage-INT-20200304.1103.0/3239363235307c44454c7c31/klnagentmac12.0.0.35.zip
link_kes_mac=https://products.s.kaspersky-labs.com/workstations/kesmac10/11.0.1.753/multilanguage-INT-20200305.1626.0/3239363237317c44454c7c31/kesmac11.0.1.753.zip
#DEFINIR PARAMETROS DE PASTAS/LOGS/DESISNTALÇÃO
#################################################
klna=/opt/kaspersky/klnagent64/bin/
kes=/opt/kaspersky/kesl/bin/
dic_temp=/tmp/kaslinux/

#Arquivos temporarios
if [ ! -d $dic_temp ]
then
mkdir -m 755 -p $dic_temp
else
rm -rf /tmp/kaslinux/*
fi

#VARIAVEL
N_arq="$0"
P_01="$1"
P_0T="$2"
INST="0"
CONF="0"

if [ "$(id -u)" != "0" ];then
  echo ""
  echo "###########################################################################"
  echo "            Voce deve ter poder de root par executar este scrip.           "
  echo "###########################################################################"
  exit 0
else
  if [[ $P_01 = "-help" ]]; then
    echo -e "\n###########################################################################"
    echo -e "       É necessario definir argumento para instalação do Kaspersky         "
    echo -e "###########################################################################\n"
    echo -e "| Argumentos |                            Ação                            |"
    echo -e "|   -yum     | Instalação Gerenciador de pacote YUM*                      |"
    echo -e "|   -deb     | Instalação Gerenciador de pacote DEB*                      |"
    echo -e "|   -dnf     | Instalaçao Gerenciador de pacote DNF*                      |"
    echo -e "|   -mac     | macOS (EM TESTE)                                           |"
    echo -e "|   -auto    | Instalação automatizada                                    |"
    echo -e "|   -conf    | Reconfigurar Kaspersky for Linux                           |"
    echo -e "|   -remover | Remover Kaspersky for Linux                                |"
    echo -e "|   -def     | Alterar configurações padrão do script                     |"
    #echo -e "|   -cupdate | Checar atualização                                         |"
    echo -e "\n * Recomendado para instalção"
    echo -e "\nExemplo: script.sh [argumento]"
    echo -e "\n###########################################################################"
    echo -e "                         Parametros opcionais                                "
    echo -e "###########################################################################\n"
    echo -e "Caso deseje definir o servidor de administração manualmente na execução do "
    echo -e "script adicione o servidor apos o argumento"
    echo -e "\nExemplo: script.sh [argumento] [KServer]"
    echo -e "\n###########################################################################\n"
    exit 0
  elif [[ $P_01 = "-yum" ]]; then
    pkg='rpm'
    INST="1"
  elif [[ $P_01 = "-deb" ]]; then
    pkg='apt'
    INST="1"
  elif [[ $P_01 = "-dnf" ]]; then
    pkg='dnf'
    INST="1"
  elif [[ $P_01 = "-mac" ]]; then
    pkg='macos'
    INST="1"
  elif [[ $P_01 = "-auto" ]]; then
    #IDENTIFICAÇÃO DE SISTEMAS OPERACIONAL
    #################################################
  macos_sys=/System/
  syst=$(cat /etc/*release* |tr '\n' '%')
  echo $syst |tr '%' '\n' >> $dic_temp'kaspersky.log'
  echo -e " * Identificando Sistema Operacional"
    if (echo $(which apt) |grep -iw apt > /dev/null); then
      echo $(which apt) >> $dic_temp'kaspersky.log'
      INST="1"
      pkg='apt'
    elif (echo $(which dnf) |grep -iw dnf > /dev/null); then
      echo $(which dnf) >> $dic_temp'kaspersky.log'
      INST="1"
      pkg='dnf'
    elif (echo $(which yum) |grep -iw yum > /dev/null); then
      echo $(which yum) >> $dic_temp'kaspersky.log'
      INST="1"
      pkg='rpm'
    elif (-d $macos_sys); then
      INST="1"
      pkg='macos'
    else
      echo "* Sistema Operacional incompativel"
      exit 0
    fi
  elif [[ $P_01 = "-conf" ]]; then
    CONF="1"
    pkg='conf'
  elif [[ $P_01 = "-remover" ]]; then
    pkg='remover'
  elif [[ $P_01 = "-def" ]]; then
    pkg='def'
  else
    echo -e "\n###########################################################################"
    echo -e "       É necessario definir argumento para instalação do Kaspersky         "
    echo -e "\n             script.sh -help (Para mais informaçoes)                     "
    echo -e "###########################################################################"
    exit 0
  fi
fi

#Checando servidor de Administração
if [[ $P_0T != "" ]]; then
 KLNAGENT_SERVER=$P_0T
 echo " * Servidor de Administração: "$KLNAGENT_SERVER
else
 echo " * Servidor de Administração: "$KLNAGENT_SERVER
fi

#Reconfigurando Script
if [[ $P_01 = "-def" ]]; then
  echo -e "\n###########################################################################"
  echo "                        Configuração Script                                  "
  echo -e "###########################################################################\n"
  #Servidor
  read -p 'Digite o novo Servidor de Administração: ' srvl
  read -p 'Digite a Porta(14000): ' p1
  if [[ -n ${p1//[0-9]/} ]]; then
    echo "Valor invalido! Tente Novamente"
    exit 0
  else
    if [[ $p1 != "" ]]; then
      V_KLNAGENT_PORT="KLNAGENT_PORT="$p1
    else
      V_KLNAGENT_PORT="KLNAGENT_PORT=14000"
    fi
  fi
  read -p 'Digite a Porta SSL(13000): ' p2
  if [[ -n ${p2//[0-9]/} ]]; then
    echo "Valor invalido! Tente Novamente"
    exit 0
  else
    if [[ $p2 != "" ]]; then
      V_KLNAGENT_SSLPORT="KLNAGENT_SSLPORT="$p2
    else
      V_KLNAGENT_SSLPORT="KLNAGENT_SSLPORT=13000"
    fi
  fi
  #Interface Grafica
  read -p 'Ativar interface Grafica:(S/N): ' GUI
  if [ $GUI = "S" ] || [ $GUI = "s" ]; then
    read -p '(Opcional) Usuario Root do sistema: ' USR
    V_USE_GUI="USE_GUI=yes"
    V_USER="USER=$USR"
  elif [ $GUI = "N" ] || [ $GUI = "n" ]; then
    V_USE_GUI="USE_GUI=no"
    V_USER="USER="
  else
    echo "Comando invalido! Tente Novamente"
    exit 0
  fi
  #Base de Dados
  read -p 'Atualizar base de dados(S/N): ' UPS
  if [ $UPS = "S" ] || [ $UPS = "s" ]; then
    V_UPDATE_EXECUTE="UPDATE_EXECUTE=yes"
  elif [ $UPS = "N" ] || [ $UPS = "n" ]; then
    V_UPDATE_EXECUTE="UPDATE_EXECUTE=no"
  else
    echo "Comando invalido! Tente Novamente"
    exit 0
  fi
  echo
  echo "Valores de Configuração"
  echo " * KLNAGENT_SERVER=$srvl"
  echo " * $V_USE_GUI"
  echo " * $V_USER"
  echo " * $V_UPDATE_EXECUTE"
  echo " * $V_KLNAGENT_PORT"
  echo " * $V_KLNAGENT_SSLPORT"
  read -p 'Deseja confirmar as alteraçoes(S\N): ' conx
  if [ $conx = "S" ] || [ $conx = "s" ]; then
    Dir_def="$(pwd)$(echo $N_arq|sed 's/^.//g')"
    Dir_def="$Dir_def"
    #Dir_def=$(pwd)$(echo $N_arq|sed 's/^.//g')
    #ServADM
    Serv_Antigo="KLNAGENT_SERVER="$KLNAGENT_SERVER
    Serv_Novo="KLNAGENT_SERVER="$srvl
    sed -i s/^$Serv_Antigo/$Serv_Novo/ '$Dir_def'

    #GUI e User
    T_USE_GUI="USE_GUI="$USE_GUI
    T_USER="USER="$USER
    sed -i "s/^$T_USE_GUI/$V_USE_GUI/" '$Dir_def'
    sed -i "s/^$T_USER/$V_USER/" '$Dir_def'

    #UPdate
    T_UPDATE_EXECUTE="UPDATE_EXECUTE="$UPDATE_EXECUTE
    sed -i "s/^$T_UPDATE_EXECUTE/$V_UPDATE_EXECUTE/" '$Dir_def'

    #portas
    T_KLNAGENT_PORT="KLNAGENT_PORT="$KLNAGENT_PORT
    T_KLNAGENT_SSLPORT="KLNAGENT_SSLPORT="$KLNAGENT_SSLPORT
    sed -i "s/^$T_KLNAGENT_PORT/$V_KLNAGENT_PORT/" '$Dir_def'
    sed -i "s/^$T_KLNAGENT_SSLPORT/$V_KLNAGENT_SSLPORT/" '$Dir_def'
    
    echo -e "Alteraçoes realizadas com sucesso!"
    exit 0
  else
    echo -e "Alteração não realizada!"
    exit 0
  fi
  exit 0

#Removendo Kaspersky
elif [[ $P_01 = "-remover" ]]; then
    #APT
    if (echo $(which apt) |grep -iw apt > /dev/null); then
      echo $(which apt) >> $dic_temp'kaspersky.log'
      echo "###########################################################################"
      echo "                        Remoçao Proteção Kaspersky                         "
      echo -e "###########################################################################"
      if [[ -d $klna ]]; then
        echo " * Realizando remoção do Kaspersky Agente"
        dpkg -r klnagent >> $dic_temp'kaspersky.log'
        dpkg -r klnagent64 >> $dic_temp'kaspersky.log'
      else
        echo " * Não foi identificado Kaspersky Agente instalado"
      fi
      if [[ -d $kes ]]; then
        echo " * Realizando remoção do Kaspersky Endpoint"
        dpkg -r kesl >> $dic_temp'kaspersky.log'
      else
        echo " * Não foi identificado Kaspersky Endpoint instalado"
      fi
      exit 0

    #DNF
    elif (echo $(which dnf) |grep -iw dnf > /dev/null); then
      echo $(which dnf) >> $dic_temp'kaspersky.log'
      if [[ -d $klna ]]; then
        echo " * Realizando remoção do Kaspersky Agente"
        rpm -e klnagent >> $dic_temp'kaspersky.log'
        rpm -e klnagent64 >> $dic_temp'kaspersky.log'
      else
        echo " * Não foi identificado Kaspersky Agente instalado"
      fi
      if [[ -d $kes ]]; then
        echo " * Realizando remoção do Kaspersky Endpoint"
        rpm -e kesl >> $dic_temp'kaspersky.log'
      else
        echo " * Não foi identificado Kaspersky Endpoint instalado"
      fi
      exit 0

    #YUM
      elif (echo $(which yum) |grep -iw yum > /dev/null); then
        echo $(which yum) >> $dic_temp'kaspersky.log'
        if [[ -d $klna ]]; then
          echo " * Realizando remoção do Kaspersky Agente"
          dnf -y remove klnagent >> $dic_temp'kaspersky.log'
          dnf -y remove klnagent64 >> $dic_temp'kaspersky.log'
        else
          echo " * Não foi identificado Kaspersky Agente instalado"
        fi
        if [[ -d $kes ]]; then
          echo " * Realizando remoção do Kaspersky Endpoint"
          dnf -y remove kesl >> $dic_temp'kaspersky.log'
        else
          echo " * Não foi identificado Kaspersky Endpoint instalado"
        fi
        exit 0

    elif (-d $macos_sys); then
      echo " * Não é possivel realizar a remoção do Kaspersky for macOS via script"
      exit 0

    else
      echo " * Sistema Operacional incompativel"
      exit 0
    fi
    exit 0
fi

#Diretorio TEMP
cd $dic_temp
####################################################################Processo de Instalação Kaspersky#################################
if [[ $INST = "1" ]]; then
echo "###########################################################################"
echo "                      Instalação Proteção Kaspersky                        "
echo -e "###########################################################################"
#Checando FANOTIFY
    echo -e " * Verificando FANOTIFY"
    if (cat /boot/config-$(uname -r) |grep -iw CONFIG_FANOTIFY=y > /dev/null); then
      if (cat /boot/config-$(uname -r) |grep -iw CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y > /dev/null); then
        echo "     - Todo o recurso do Fanotify é suportado pelo o Sitema Operacional."
      else
        echo -e "     - Fanotify não é suportado no Kernel. (PS1)"
        if [[ $pkg = 'apt' ]]; then
         apt install -y perl libc6 libc6-dev libc6-i386 libc6-dev-i386 gcc binutils make rpcbind >> $dic_temp'kaspersky.log'
        elif [[ $pkg = 'rpm' ]]; then
         yum install -y kernel-devel perl wget gcc glibc glibc-devel glibc.i686 make rpcbind binutils >> $dic_temp'kaspersky.log'
        elif [[ $pkg = 'dnf' ]]; then
         dnf install -y kernel-devel perl wget gcc glibc glibc-devel glibc.i686 make rpcbind binutils >> $dic_temp'kaspersky.log'
        elif [[ $pkg = 'macos' ]]; then
         echo "macOS"
        fi
      fi
    else
      echo -e "     - Fanotify não é suportado no Kernel. (PS2)"
      if [[ $pkg = 'apt' ]]; then
        apt install -y perl libc6 libc6-dev libc6-i386 libc6-dev-i386 gcc binutils make rpcbind >> $dic_temp'kaspersky.log'
      elif [[ $pkg = 'rpm' ]]; then
        yum install -y kernel-devel perl wget gcc glibc glibc-devel glibc.i686 make rpcbind binutils >> $dic_temp'kaspersky.log'
      elif [[ $pkg = 'dnf' ]]; then
        dnf install -y kernel-devel perl wget gcc glibc glibc-devel glibc.i686 make rpcbind binutils >> $dic_temp'kaspersky.log'
      elif [[ $pkg = 'macos' ]]; then 
        echo "macOS"
      fi
    fi
    
#Instalação APT
    if [[ $pkg = 'apt' ]]; then
        if [[ -d $klna ]]; then
          echo " * Realizando remoção de versoes anteriores do Kaspersky Agente"
          dpkg -r klnagent >> $dic_temp'kaspersky.log'
          dpkg -r klnagent64 >> $dic_temp'kaspersky.log'
        fi
        if [[ -d $kes ]]; then
          echo " * Realizando remoção de versoes anteriores do Kaspersky Endpoint"
          dpkg -r kesl >> $dic_temp'kaspersky.log'
        fi
        echo " * Download do Agente de Rede"
        wget -q -c -O $dic_temp'KLA.deb' -P $dic_temp $link_kla_deb
        echo " * Instalando Kaspersky Agente de Rede"
        dpkg -i $dic_temp'KLA.deb' >> $dic_temp'kaspersky.log'
        echo " * Instação do Agente de Rede completa"
        echo " * Download do Kaspersky Endpoint"
        wget -q -c -O $dic_temp'KES.deb' -P $dic_temp $link_kes_deb
        echo " * Instalando Kaspersky Endpoint"
        dpkg -i $dic_temp'KES.deb' >> $dic_temp'kaspersky.log'
        echo " * Instalação do Kaspersky Endpoint completa"

    #Instalação RPM
    elif [[ $pkg = 'rpm' ]]; then
        if [[ -d $klna ]]; then
          echo " * Realizando remoção de versoes anteriores do Kaspersky Agente"
          rpm -e klnagent >> $dic_temp'kaspersky.log'
          rpm -e klnagent64 >> $dic_temp'kaspersky.log'
        fi
        if [[ -d $kes ]]; then
          echo " * Realizando remoção de versoes anteriores do Kaspersky Endpoint"
          rpm -e kesl >> $dic_temp'kaspersky.log'
        fi
        echo " * Download do Agente de Rede"
        wget -q -c -O $dic_temp'KLA.rpm' -P $dic_temp $link_kla_rpm
        echo " * Instalando Kaspersky Agente de Rede"
        rpm -ivh $dic_temp'KLA.rpm' >> $dic_temp'kaspersky.log'
        echo " * Instalação do Agente de Rede completa"
        echo " * Download do Kaspersky Endpoint"
        wget -q -c -O $dic_temp'KES.rpm' -P $dic_temp $link_kes_rpm
        echo " * Instalando Kaspersky Endpoint"
        rpm -ivh $dic_temp'KES.rpm' >> $dic_temp'kaspersky.log'
        echo " * Instalação Kaspersky Endpoint completa"

    #Instalação DNF
    elif [[ $pkg = 'dnf' ]]; then
        if [[ -d $klna ]]; then
          echo " * Realizando remoção de versoes anteriores do Kaspersky Agente"
          dnf -y remove klnagent >> $dic_temp'kaspersky.log'
          dnf -y remove klnagent64 >> $dic_temp'kaspersky.log'
        fi
        if [[ -d $kes ]]; then
          echo " * Realizando remoção de versoes anteriores do Kaspersky Endpoint"
          dnf -y remove kesl >> $dic_temp'kaspersky.log'
        fi
        echo " * Download do Agente de Rede"
        wget -q -c -O $dic_temp'KLA.rpm' -P $dic_temp $link_kla_rpm
        echo " * Instalando Kaspersky Agente de Rede"
        dnf install -y $dic_temp'KLA.rpm' >> $dic_temp'kaspersky.log'
        echo " * Instalação do Agente de Rede completa"
        echo " * Download do Kaspersky Endpoint"
        wget -q -c -O $dic_temp'KES.rpm' -P $dic_temp $link_kes_rpm
        echo " * Instalando Kaspersky Endpoint"
        dnf install -y $dic_temp'KES.rpm' >> $dic_temp'kaspersky.log'
        echo " * Instalação Kaspersky Endpoint completa"

    #Instalação macOS
    elif [[ $pkg = 'macos' ]]; then
        echo " * Download do Agente de Rede macOS"
        curl -o $dic_temp'kla.zip' $link_ag_mac
        unzip $dic_temp'kla.zip' -d $dic_temp'kla'
        $dic_temp'kla'install.sh --accept_eula -r $KLNAGENT_SERVER -p $KLNAGENT_PORT -s use_ssl:1 -l $KLNAGENT_SSLPORT
        echo " * Instalação do Kaspersky Agente de Rede macOS completa"
        echo " * Download do Kaspersky Endpoint macOS"
        curl -o $dic_temp'kes.zip' $link_kes_mac
        unzip $dic_temp'kes.zip' -d $dic_temp'kes'
        $dic_temp'kes'/install.sh --accept_eula --accept_ksn_eula
        echo " * Instalação do Kaspersky Endpoint macOS completa"
        exit 0
    fi
CONF="1"
fi

if [[ $CONF = "1" ]]; then
echo "###########################################################################"
echo "                     Configuração Proteção Kaspersky                       "
echo -e "###########################################################################"
  if [ $pkg = "apt" ] || [ $pkg = "rpm" ] || [ $pkg = "dnf" ] || [ $pkg = "conf" ]; then
      if [[ -d $klna ]]; then
        echo " * Gerando arquivo de configuração Agente de Rede"
        touch $dic_temp'kesl_autoanswers.conf'
        echo -e "KLNAGENT_SERVER=$KLNAGENT_SERVER\nKLNAGENT_PORT=$KLNAGENT_PORT\nKLNAGENT_SSLPORT=$KLNAGENT_SSLPORT\nKLNAGENT_USESSL=$KLNAGENT_USESSL\nKLNAGENT_GW_MODE=$KLNAGENT_GW_MODE" >> $dic_temp'autoanswers.conf'
        echo " * Configurando Agente de Rede"
        /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl --auto
        echo " * Agente de Rede Configurado"
      else
        echo " * Não foi identificado Kaspersky Agente instalado"
      fi
      if [[ -d $kes ]]; then
        echo " * Gerando arquivo de configuração Endpoint"
        touch $dic_temp'kesl_autoanswers.conf'
        echo -e "EULA_AGREED=$EULA_AGREED\nPRIVACY_POLICY_AGREED=$PRIVACY_POLICY_AGREED\nUSE_KSN=$USE_KSN\nUPDATER_SOURCE=$UPDATER_SOURCE\nUPDATE_EXECUTE=$UPDATE_EXECUTE\nUSE_GUI=$USE_GUI\nIMPORT_SETTINGS=$IMPORT_SETTINGS\nADMIN_USER_IF_USE_GUI=$USER" >> $dic_temp'kesl_autoanswers.conf'
        echo " * Configurando Kaspersky Endpoint"
        /opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=$dic_temp'kesl_autoanswers.conf'
        echo " * Endpoint Configurado"
      else
        echo " * Não foi identificado Kaspersky Endpoint instalado"
      fi
      exit 0
  fi
fi

#Configurando Kaspersky
#    if [ $pkg = "apt" ] || [ $pkg = "rpm" ] || [ $pkg = "dnf" ] || [ $pkg = "conf" ]; then
#      echo " * Gerando arquivo de configuração Agente de Rede"
#      touch $dic_temp'kesl_autoanswers.conf'
#      echo -e "KLNAGENT_SERVER=$KLNAGENT_SERVER\nKLNAGENT_PORT=$KLNAGENT_PORT\nKLNAGENT_SSLPORT=$KLNAGENT_SSLPORT\nKLNAGENT_USESSL=$KLNAGENT_USESSL\nKLNAGENT_GW_MODE=$KLNAGENT_GW_MODE" >> $dic_temp'autoanswers.conf'
#      echo " * Configurando Agente de Rede"
#      /opt/kaspersky/klnagent64/lib/bin/setup/postinstall.pl --auto
#      echo " * Agente de Rede Configurado"
#      echo " * Gerando arquivo de configuração Endpoint"
#      touch $dic_temp'kesl_autoanswers.conf'
#      echo -e "EULA_AGREED=$EULA_AGREED\nPRIVACY_POLICY_AGREED=$PRIVACY_POLICY_AGREED\nUSE_KSN=$USE_KSN\nUPDATER_SOURCE=$UPDATER_SOURCE\nUPDATE_EXECUTE=$UPDATE_EXECUTE\nUSE_GUI=$USE_GUI\nIMPORT_SETTINGS=$IMPORT_SETTINGS\nADMIN_USER_IF_USE_GUI=$USER" >> $dic_temp'kesl_autoanswers.conf'
#      echo " * Configurando Kaspersky Endpoint"
#      /opt/kaspersky/kesl/bin/kesl-setup.pl --autoinstall=$dic_temp'kesl_autoanswers.conf'
#      echo " * Endpoint Configurado"
#      exit 0
#    fi
#fi
#Desenvolvido por ZEROPROJ
