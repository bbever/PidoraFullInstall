sudo apt-get install -y git libao-dev libmad0-dev libfaad-dev libgnutls-dev libjson0-dev libgcrypt11-dev pkg-config make

git clone https://github.com/PromyLOPh/pianobar.git
git clone https://github.com/FFmpeg/FFmpeg.git
git clone https://github.com/bbever/pidora.git

cd FFmpeg/
./configure --enable-shared --disable-everything --enable-demuxer=mov --enable-decoder=aac --enable-protocol=http --enable-filter=volume --enable-filter=aformat --enable-filter=aresample --disable-programs --disable-doc
make
sudo make install
LD_LIBRARY_PATH=/usr/local/lib
sudo ldconfig

cd ../pianobar
make
sudo make install

cd ..
mkdir .config
mkdir .config/pianobar
touch .config/pianobar/config
touch .config/pianobar/state

sudo mkdir /.config
sudo mkdir /.config/pianobar
sudo ln -s /home/pi/.config/pianobar/state state
sudo ln -s /home/pi/.config/pianobar/config config


cd $HOME
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
sudo python get-pip.py
sudo pip install requests
sleep 5
clear
echo "Starting to set up pianobar"
read -p "What is your Pandora email address? " username
read -p "What is your Pandora pasword? " password
echo "user = $username
password = $password" > ~/.config/pianobar/config
fingerprint=`openssl s_client -connect tuner.pandora.com:443 < /dev/null 2> /dev/null | openssl x509 -noout -fingerprint | tr -d ':' | cut -d'=' -f2` && echo tls_fingerprint = $fingerprint >> ~/.config/pianobar/config
echo
echo "Testing Pianobar. It should log in and ask you to select a station."
echo "After selecting the station, pianobar will print the station's name and a long ID number. This will be the default station. Copy that number to the clipboard."
echo "Press q to quit at any time."
read -n1 -r -p "Press any key to continue..."
echo
pianobar
echo
cd $HOME
clear
sed -i "s,/home/pi,$HOME," cpy.conf
echo
mkfifo pidora/ctl
echo "event_command = $HOME/pidora/bar-update.py
fifo = $HOME/pidora/ctl" >> ~/.config/pianobar/config

sudo sed -i "$isleep 5" /etc/rc.local
sudo sed -i "$ipython $HOME/pidora/hello.py &" /etc/rc.local
sudo sed -i "$i " /etc/rc.local
