#!/bin/bash
# Pulls latest pre-built node binary from GitHub and installs it as a systemd service.
# Intended for non-technical validators, assumes running on compatible Ubuntu.

#stop on errors
set -e

#running as root gives the wrong homedir, check and exit if run with sudo.
if ((EUID == 0)); then
    echo "The script is not designed to run as root user. Please run it without sudo prefix."
    exit
fi

#helper function to create metalgo.service file
create_service_file () {
  rm -f metalgo.service
  echo "[Unit]">>metalgo.service
  echo "Description=MetalGo systemd service">>metalgo.service
  echo "StartLimitIntervalSec=0">>metalgo.service
  echo "[Service]">>metalgo.service
  echo "Type=simple">>metalgo.service
  echo "User=$(whoami)">>metalgo.service
  echo "WorkingDirectory=$HOME">>metalgo.service
  echo "ExecStart=$HOME/metal-node/metalgo --config-file=$HOME/.metalgo/configs/node.json">>metalgo.service
  echo "LimitNOFILE=32768">>metalgo.service
  echo "Restart=always">>metalgo.service
  echo "RestartSec=1">>metalgo.service
  echo "[Install]">>metalgo.service
  echo "WantedBy=multi-user.target">>metalgo.service
  echo "">>metalgo.service
}

create_config_file () {
  rm -f node.json
  echo "{" >>node.json
  if [ "$rpcOpt" = "any" ]; then
    echo "  \"http-host\": \"\",">>node.json
  fi
  if [ "$adminOpt" = "true" ]; then
    echo "  \"api-admin-enabled \": \"true\",">>node.json
  fi
  if [ "$indexOpt" = "true" ]; then
    echo "  \"index-enabled\": \"true\",">>node.json
  fi
  if [ "$tahoeOpt" = "true" ]; then
    echo "  \"network-id\": \"tahoe\",">>node.json
  fi
  if [ "$dbdirOpt" != "no" ]; then
    echo "  \"db-dir\": \"$dbdirOpt\",">>node.json
  fi
  if [ "$ipChoice" = "1" ]; then
    echo "  \"public-ip-resolution-service\": \"opendns\"">>node.json
  else
    echo "  \"public-ip\": \"$foundIP\"">>node.json
  fi
  echo "}" >>node.json
  mkdir -p $HOME/.metalgo/configs
  cp -f node.json $HOME/.metalgo/configs/node.json

  rm -f config.json
  echo "{" >>config.json
  if [ "$archivalOpt" = "true" ]; then
    echo "  \"pruning-enabled\": \"false\"">>config.json
  fi
  echo "}" >>config.json
  mkdir -p $HOME/.metalgo/configs/chains/C
  cp -f config.json $HOME/.metalgo/configs/chains/C/config.json
}

remove_service_file () {
  if test -f "/etc/systemd/system/metalgo.service"; then
    sudo systemctl stop metalgo
    sudo systemctl disable metalgo
    sudo rm /etc/systemd/system/metalgo.service
  fi
}

#helper function to check for presence of required commands, and install if missing
check_reqs () {
  if ! command -v curl &> /dev/null
  then
      echo "curl could not be found, will install..."
      sudo apt-get install curl -y
  fi
  if ! command -v wget &> /dev/null
  then
      echo "wget could not be found, will install..."
      sudo apt-get install wget -y
  fi
  if ! command -v dig &> /dev/null
  then
      echo "dig could not be found, will install..."
      sudo apt-get install dnsutils -y
  fi
}

#helper function that prints usage
usage () {
  echo "Usage: $0 [--list | --help | --reinstall | --remove] [--version <tag>] [--ip dynamic|static|<IP>]"
  echo "                     [--RPC local|all] [--archival] [--index] [--db-dir <path>]"
  echo "Options:"
  echo "   --help            Shows this message"
  echo "   --list            Lists 10 newest versions available to install"
  echo "   --reinstall       Run the installer from scratch, overwriting the old service file and node configuration"
  echo "   --remove          Remove the system service and MetalGo binaries and exit"
  echo ""
  echo "   --version <tag>          Installs <tag> version, default is the latest"
  echo "   --ip dynamic|static|<IP> Uses dynamic, static (autodetect) or provided public IP, will ask if not provided"
  echo "   --rpc local|any          Open RPC port (9650) to local or all network interfaces, will ask if not provided"
  echo "   --archival               If provided, will disable state pruning, defaults to pruning enabled"
  echo "   --index                  If provided, will enable indexer and Index API, defaults to disabled"
  echo "   --db-dir <path>          Full path to the database directory, defaults to $HOME/.metalgo/db"
  echo "   --tahoe                  Connect to Tahoe testnet, defaults to mainnet if omitted"
  echo "   --admin                  Enable Admin API, defaults to disabled if omitted"
  echo ""
  echo "Run without any options, script will install or upgrade MetalGo to latest available version. Node config"
  echo "options for version, ip and others will be ignored when upgrading the node, run with --reinstall to change config."
  echo "Reinstall will not modify the database or NodeID definition, it will overwrite node and chain configs."
  exit 0
}

list_versions () {
  echo "Available versions:"
  wget -q -O - https://api.github.com/repos/MetalBlockchain/metalgo/releases \
  | grep tag_name \
  | sed 's/.*: "\(.*\)".*/\1/' \
  | head
  exit 0
}

# Argument parsing convenience functions.
usage_error () { echo >&2 "$(basename $0):  $1"; exit 2; }
assert_argument () { test "$1" != "$EOL" || usage_error "$2 requires an argument"; }

#initialise options
tahoeOpt="no"
adminOpt="no"
rpcOpt="ask"
indexOpt="no"
archivalOpt="no"
dbdirOpt="no"
ipOpt="ask"

echo "MetalGo installer"
echo "---------------------"

# process command line arguments
if [ "$#" != 0 ]; then
  EOL=$(echo '\01\03\03\07')
  set -- "$@" "$EOL"
  while [ "$1" != "$EOL" ]; do
    opt="$1"; shift
    case "$opt" in
      --list) list_versions ;;
      --version) assert_argument "$1" "$opt"; version="$1"; shift;;
      --reinstall) #recreate service file and install
        echo "Will reinstall the node."
        remove_service_file
        ;;
      --remove) #remove the service and node files
        echo "Removing the service..."
        remove_service_file
        echo "Remove node binaries..."
        rm -rf $HOME/metal-node
        echo "Done."
        echo "MetalGo removed. Working directory ($HOME/.metalgo/) has been preserved."
        exit 0
        ;;
      --help) usage ;;
      --ip) assert_argument "$1" "$opt"; ipOpt="$1"; shift;;
      --rpc) assert_argument "$1" "$opt"; rpcOpt="$1"; shift;;
      --archival) archivalOpt='true';;
      --index) indexOpt='true';;
      --db-dir) assert_argument "$1" "$opt"; dbdirOpt="$1"; shift;;
      --tahoe) tahoeOpt='true';;
      --admin) adminOpt='true';;

      -|''|[!-]*) set -- "$@" "$opt";;                                          # positional argument, rotate to the end
      --*=*)      set -- "${opt%%=*}" "${opt#*=}" "$@";;                        # convert '--name=arg' to '--name' 'arg'
      --)         while [ "$1" != "$EOL" ]; do set -- "$@" "$1"; shift; done;;  # process remaining arguments as positional
      -*)         usage_error "unknown option: '$opt'";;                        # catch misspelled options
      *)          usage_error "this should NEVER happen ($opt)";;               # sanity test for previous patterns

    esac
  done
  shift  # $EOL
fi

echo "Preparing environment..."
check_reqs
foundIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
foundArch="$(uname -m)"                         #get system architecture
foundOS="$(uname)"                              #get OS
if [ "$foundOS" != "Linux" ]; then
  #sorry, don't know you.
  echo "Unsupported operating system: $foundOS!"
  echo "Exiting."
  exit
fi
if [ "$foundArch" = "aarch64" ]; then
  getArch="arm64"                               #we're running on arm arch (probably RasPi)
  echo "Found arm64 architecture..."
elif [ "$foundArch" = "x86_64" ]; then
  getArch="amd64"                               #we're running on intel/amd
  echo "Found amd64 architecture..."
else
  #sorry, don't know you.
  echo "Unsupported architecture: $foundArch!"
  echo "Exiting."
  exit
fi
if test -f "/etc/systemd/system/metalgo.service"; then
  foundMetalGo=true
  echo "Found MetalGo systemd service already installed, switching to upgrade mode."
  echo "Stopping service..."
  sudo systemctl stop metalgo
else
  foundMetalGo=false
fi
# download and copy node files
mkdir -p /tmp/metalgo-install               #make a directory to work in
rm -rf /tmp/metalgo-install/*               #clean up in case previous install didn't
cd /tmp/metalgo-install

version=${version:-latest}
echo "Looking for $getArch version $version..."
if [ "$version" = "latest" ]; then
  fileName="$(curl -s https://api.github.com/repos/MetalBlockchain/metalgo/releases/latest | grep "metalgo-linux-$getArch.*tar\(.gz\)*\"" | cut -d : -f 2,3 | tr -d \" | cut -d , -f 2)"
else
  fileName="https://github.com/MetalBlockchain/metalgo/releases/download/$version/metalgo-linux-$getArch-$version.tar.gz"
fi
if [[ `wget -S --spider $fileName  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  echo "Node version found."
else
  echo "Unable to find MetalGo version $version. Exiting."
  if [ "$foundMetalGo" = "true" ]; then
    echo "Restarting service..."
    sudo systemctl start metalgo
  fi
  exit
fi
echo "Attempting to download: $fileName"
wget -nv --show-progress $fileName
echo "Unpacking node files..."
mkdir -p $HOME/metal-node
tar xvf metalgo-linux*.tar.gz -C $HOME/metal-node --strip-components=1;
rm metalgo-linux-*.tar.gz
echo "Node files unpacked into $HOME/metal-node"
echo
if [ "$foundMetalGo" = "true" ]; then
  echo "Node upgraded, starting service..."
  sudo systemctl start metalgo
  echo "New node version:"
  $HOME/metal-node/metalgo --version
  echo "Done!"
  exit
fi
if [ "$ipOpt" = "ask" ]; then
  echo "To complete the setup, some networking information is needed."
  echo "Where is your node running?"
  echo "1) Residential network (dynamic IP)"
  echo "2) Cloud provider (static IP)"
  ipChoice="x"
  while [ "$ipChoice" != "1" ] && [ "$ipChoice" != "2" ]
  do
    read -p "Enter your connection type [1,2]: " ipChoice
  done
  if [ "$ipChoice" = "1" ]; then
    echo "Installing service with dynamic IP..."
  else
    read -p "Detected '$foundIP' as your public IP. Is this correct? [y,n]: " correct
    if [ "$correct" != "y" ]; then
      read -p "Enter your public IP: " foundIP
      if [[ ! $foundIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        check=false               # ensure its a valid IP
      else
        check=true
      fi
      while [[ $check == false ]]
      do
         read -p "Invalid IP. Please Enter your public IP: " foundIP
         if [[ $foundIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
              check=true
         fi
      done
    fi
    echo "Installing service with public IP: $foundIP"
  fi
elif [ "$ipOpt" = "dynamic" ]; then
  echo "Installing service with dynamic IP..."
  ipChoice="1"
elif [ "$ipOpt" = "static" ]; then
  echo "Detected '$foundIP' as your public IP."
  ipChoice="2"
else
  if [[ ! $ipOpt =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Provided IP ($ipOpt) does not look correct! Exiting."
    exit 1
  fi
  echo "Will use provided IP ($ipOpt) as public IP."
  foundIP="$ipOpt"
  ipChoice="2"
fi
echo ""
echo "Your node can accept RPC calls on port 9650. If restricted to local, it will be accessible only from this machine."
while [ "$rpcOpt" != "any" ] && [ "$rpcOpt" != "local" ]
do
  read -p "Do you want the RPC port to be accessible to any or only local network interface? [any, local]: " rpcOpt
done
if [ "$rpcOpt" = "any" ]; then
  echo "RPC port will be accessible on any interface. Make sure you configure the firewall to only let through RPC requests"
  echo "from known IP addresses, otherwise your node might be overwhelmed by RPC calls from malicious actors!"
fi
if [ "$rpcOpt" = "local" ]; then
  echo "RPC port will be accessible only on local interface. RPC calls from remote machines will be blocked."
fi
echo ""
if [ "$indexOpt" = "true" ]; then
  echo "Node indexing is enabled. Note that existing nodes need to bootstrap again to fill in the missing indexes."
  echo ""
fi
if [ "$archivalOpt" = "true" ]; then
  echo "Node pruning is disabled, node is running in archival mode."
  echo "Note that existing nodes need to bootstrap again to fill in the missing data."
  echo ""
fi
if [ "$adminOpt" = "true" ]; then
  echo "Admin API on the node is enabled."
  echo ""
fi
if [ "$tahoeOpt" = "true" ]; then
  echo "Node is connected to the Tahoe test network."
  echo ""
fi
if [ "$dbdirOpt" != "no" ]; then
  echo "Node database directory is set to: $dbdirOpt"
  echo ""
fi
create_config_file
create_service_file
chmod 644 metalgo.service
sudo cp -f metalgo.service /etc/systemd/system/metalgo.service
sudo systemctl daemon-reload
sudo systemctl start metalgo
sudo systemctl enable metalgo
echo
echo "Done!"
echo
echo "Your node should now be bootstrapping."
echo "Node configuration file is $HOME/.metalgo/configs/node.json"
echo "C-Chain configuration file is $HOME/.metalgo/configs/chains/C/config.json"
echo "To check that the service is running use the following command (q to exit):"
echo "sudo systemctl status metalgo"
echo "To follow the log use (ctrl-c to stop):"
echo "sudo journalctl -u metalgo -f"