clear
echo '
SAMBA INSTALLER ...

by seveN
'
sleep 2
sudo apt update 
sudo apt install samba

clear

echo 'part 1 Done..'

echo

sudo mkdir /home/sharedF
sudo chmod 777 /home/sharedF

echo
echo 'part 2 Done...'

echo
sudo adduser seven
sudo smbpasswd -a seven
echo 


rm -mv /etc/samba/smb.conf /etc/samba/defult_smb.conf
cp smb.conf /etc/samba
echo

echo 'part 3 Done...'
echo
sudo service smbd restart
sudo ufw allow samba

echo 'Install Done'

echo
ifconfig
sleep 2

service smbd status 
