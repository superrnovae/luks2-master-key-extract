## Recover a luks2 master-key from a kernel memory dump.

This is an instruction for myself if I ever end up in the same situation again. Though it might also be useful for those who have accidentally wiped a key slot off of their luks2 device and no longer have access to a passphrase. 

### Pre-requisites: 

 * Turned off secure boot
 * Root access
 * Opened luks2 partition
 
Since the deprecation of /dev/kmem, linux no longer provides access to kernel's address space from the userland.

Thankfully, there is an out of tree kernel module LiME, that we can load to acquire volatile memory from Linux and Linux-based devices.

The instructions have been tested on Fedora, but can be adjusted to work on other distributions.

### Steps: 

 1. Install dependencies

	`sudo dnf install -y curl podman unzip python3`

	Download and unzip the [findaes](https://sourceforge.net/projects/findaes/files/findaes-1.2.zip/download) utility
   
 2. Clone this repository

 	`git clone https://github.com/superrnovae/luks2-master-key-extract.git`
 
 3. Build the module
 
 	`sudo ./lime-module build`
 
 4. Load the module
 
 	`sudo ./lime-module load`

	Note: it may take a while, also expect possible freezes.   

	The dump will be located in the /opt directory.
 
 5. Search for aes keys in the dump

	```
	chmod +x findaes
	sudo ./findaes dump > keys
	```   

	You will find the output in the file named 'keys'

 6. Modify the device variable in script.py to fit your setup.

 7.  Run python script. (You will be asked to provide sudo password)

	We will need a pair of 256 bit keys that are consecutive in the memory. You can do that by hand, or you can use the script as described below.   
	
	`python3 ./script.py`
	

	The script will automate the process for us by reading the output provided by findaes and generate master-keys in binary format. After that it will run `cryptsetup luksAddKey` command using generated binary files as --master-key-file argument.


 8. Set new passphrase when asked.   

 9. Use any of the available tools to securely delete all generated files.
 
 ---
 
### Articles
 - [Breaking full disk encryption from a memory dump](https://blog.appsecco.com/breaking-full-disk-encryption-from-a-memory-dump-5a868c4fc81e)
 - [Open encrypted luks volume](https://heisenberk.github.io/Open-Encrypted-LUKS-Volume/)
