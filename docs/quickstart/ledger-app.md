# Installing the Ledger Nano app

## Intro

The Metal Ledger Nano application allows users to store their assets on a Ledger Nano S and Nano S Plus while interacting with the Metal Blockchain. Unfortunately, as the Metal Blockchain is still relatively new users will need to manually install the app on their Ledger devices. This is a rather technical process and can be tricky for a lot of users.

For those who are eager to use their Ledger device with the Metal Blockchain Wallet right away after our mainnet launch, this guide provides an alternative method to install the Metal app onto a Ledger Nano S via a process called “sideloading”.

## About Sideloading

Sideloading means directly downloading the Metal Ledger app to your computer, and from there loading it onto your Ledger device without using the Ledger Live application. Because sideloading requires no support from Ledger HQ, it is the typical approach for very new integrations on Ledger devices like ours.

Ledger HQ provides a method for sideloading apps onto Ledger devices – but it is a very manual process using unix-based tools that require a bit of getting “under the hood” of your computer. The process will probably feel comfortable to a software developer, but for others it will feel a bit strange. We’ll do our best, however, to lead you through it step by step. And in the end, you can rest assured that once the app is loaded onto your Ledger, it will not brick your Ledger and it will be just as secure as installing via Ledger Live.

:::warning

Sideloading is **only possible for a Ledger Nano S and Ledger Nano S Plus**. The Ledger Nano X doesn't allow sideloading unfortunately.

:::

### MacOS Sideloading

#### Install Homebrew

Homebrew is a package manager for MacOS and will be necessary for the other packages we'll need to install. Skip this step if you already have Homebrew installed. If not, run the command in the **Terminal** app below:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Install Pre-requisites

```sh
brew install python3 wget
```

#### Install and setup virtualenv

```sh
pip3 install virtualenv --user
```

Next we'll need to setup a virtual environment for our Ledger installation:

```sh
mkdir -p ~/Metal && python3 -m venv ~/Metal/env
```

Now we load up the virtual environment for the next steps:

```sh
source ~/Metal/env/bin/activate
```

Then we can install Ledger HQ’s sideloading tool “ledgerblue”:

```sh
pip3 install ledgerblue
```

Then we go into the folder where we earlier put the Metal Ledger app source code:

```sh
cd ~/Metal
```

Now we’re finally ready to do the sideload.

At this point, **connect your Ledger Nano S with its USB cable, and unlock it with your PIN**. You should see the Ledger’s menu on the device screen, where you might have a Bitcoin or Ethereum app if you installed one of these already.

:::info

Once again – **do not open the Ledger Live application on the computer!** You only need to connect the Ledger device itself.

Also, make sure that you don’t launch any Ledger apps on the Ledger device (such as a Bitcoin or Ethereum app. You simply need to enter your PIN and wait at the main menu.

:::

Once the Ledger device is connected and ready, we’re going to do one last Terminal command that will perform the sideload install:

For the **Ledger Nano S** execute the following command:

```sh
wget https://github.com/MetalBlockchain/ledger-app-metal/releases/download/v0.6.0/ledger_nanos.zip
unzip ledger_nanos.zip
```

```sh
python -m ledgerblue.loadApp \
--appFlags 0x00 \
--dataSize $((0x`cat debug/app.map |grep _envram_data | tr -s ' ' | cut -f2 -d' '|cut -f2 -d'x'` - 0x`cat debug/app.map |grep _nvram_data | tr -s ' ' | cut -f2 -d' '|cut -f2 -d'x'`)) \
--tlv \
--curve ed25519 \
--curve secp256k1 \
--curve secp256r1 \
--targetId 0x31100004 \
--delete \
--path '44'\''/60'\''' \
--path '44'\''/9000'\''' \
--fileName bin/app.hex \
--appName Metal \
--appVersion 0.6.0 \
--icon 0100000000ffffff00ffffffffffffffffcff38ff18ff10ff04ff24ffecff3cff3ffffffffffffffff
```

For the **Ledger Nano S Plus** execute the following command:

```sh
wget https://github.com/MetalBlockchain/ledger-app-metal/releases/download/v0.6.0/ledger_nanos_plus.zip
unzip ledger_nanos_plus.zip
```

```sh
python -m ledgerblue.loadApp \
--appFlags 0x00 \
--dataSize $((0x`cat debug/app.map |grep _envram_data | tr -s ' ' | cut -f2 -d' '|cut -f2 -d'x'` - 0x`cat debug/app.map |grep _nvram_data | tr -s ' ' | cut -f2 -d' '|cut -f2 -d'x'`)) \
--tlv \
--curve ed25519 \
--curve secp256k1 \
--curve secp256r1 \
--targetId 0x33100004 \
--delete \
--path '44'\''/60'\''' \
--path '44'\''/9000'\''' \
--fileName bin/app.hex \
--appName Metal \
--appVersion 0.6.0 \
--icon 0100000000ffffff00000000000060183807ce817f601bd800868161000000000000
```

#### Steps to follow on the Ledger

You’ll now start seeing more strange text in the Terminal, but this time you’ll be asked to confirm some things on your Ledger Nano S (Plus) device itself using its buttons.

First, you should see:

```
Deny unsafe manager
```

Don’t panic about this being an “unsafe manager”! This is just your Ledger device being suitably cautious about sideloaded apps. In this case we trust what we are loading and so we can safely ignore this warning.

Here you will need to use the device’s right button to advance through some screens before you get to a screen where you can use both buttons to confirm that you want to allow the “unsafe manager”, like this:

```
> public key (9 screens) > Allow unsafe manager
```

You may see a warning about a “broken certificate chain” in Terminal here. You can safely ignore this.

Shortly, you should see on your Ledger screen:

```
Loading, please wait
```

Once the progress bar fills, this will be followed by:

```
Install app Metal
```

Here again you will have to use the device’s right button to advance through some screens before you get to a screen where you can use both buttons to confirm like this:

```
Version > Identifier (5 screens) > Code Identifier (5 screens) > Perform Installation
```

Note: The “Version” screen may not actually show any version information. Again, this is normal and expected for this sideloading process.

Then you’ll be asked to **enter your Ledger’s PIN again**. Once you do so, momentarily you should be returned to your prompt in Terminal.

**You’ve just completed the sideload!**


:::info

If this last command failed, check that you are indeed on the latest Ledger firmware, that your Ledger is connected with the PIN entered, and that you have enough space remaining on your Ledger. You may have to remove one or two other Ledger apps if you do not have enough space.

:::