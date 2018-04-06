**Make sure to change the name of the head node in the mom_priv.config.sample file.**

### Introduction

The entire process can be broken down into these steps:

 + Get a minimum of two nodes, although three is recommended.

 + Install PBSPro from source on the head node

 + Configure the hostnames of all the hosts in the ```/etc/hosts``` file.

 + Install pdsh on the head node by running ```sudo apt install pdsh```

### Configuring Passwordless SSH

 + Configure passwordless ssh by generating the rsa keys of the master and adding the public key as authorized_keys in all the nodes. 

	+ On the **master** run ssh-keygen -t rsa
	+ Leave all options as default
	+ Now move the content of the file ```~/.ssh/id_rsa.pub``` to ```~/.ssh/authorized_keys``` in all the nodes which you want to make as compute nodes.
	+ ```chmod -R 700 ~/.ssh```
	+ ```chmod 600 ~/.ssh/*```
	+ ```service ssh restart```

Now you can try doing something like ```ssh hostname``` and it should work without prompting you for the password.

### Configuring PDSH
You may require ```sudo``` privileges for the commands given below

+ ```sudo apt install pdsh```
+ ```vim /etc/profile.d/pdsh.sh```
+ Write these lines in the file:

```bash
export PDSH_RCMD_TYPE='ssh'
export WCOLL='/etc/pdsh/machines'
```
+ ```vim /etc/pdsh/machines/```
+ Write the hostnames of all the compute nodes in this file like this:

```bash
node1
node2
node3
.......
.......
```
+ Also create a file ```/etc/genders``` which contains the same data as given in the above file.

+ ```echo "ssh" > /etc/pdsh/rcmd_default```

+ now you can test pdsh by running some simple test command like:

   ```pdsh -A "ls /"```
	
	This should output the result of ls from all the nodes as the command is run in parallel.
	
So now, we can easily run commands in parallel and can ssh into hosts without any passwords.

### Configuring the head node

Now, clone this repository and run ```install.sh``` on the master node of the pbs cluster.

Make sure that the ```/etc/hosts``` file contains the list of all nodes and the master across all the nodes of the cluster.

### Configuring the compute nodes
Now use pdsh to execute the commands given in the ```install_compute_node.sh``` file. All these commands can be run on parallel across all the nodes at once.

Also make sure to copy the contents of the file ```mom_priv.config.sample``` at ```/var/spool/pbs/mom_priv/config``` and be sure the change the hostname to the hostname of the master node.
The copying can be done using ```$ pdcp``` command.

After configuring the compute nodes, come back on the head node and then create the nodes using ```qmgr```

By default only the root user can use qmgr, so we use ```sudo su``` and drop to the root shell prompt. To create a new node run:

```qmgr -c create node <hostname>```

This can be a bit tedious if you have a lot of clients and thus a simple way to work around it would be to create a file hostnames of all the nodes and then using a simple shell script to make all the compute nodes.

Restart PBS service on all the nodes and the master by issuing the command:

```sudo /etc/init.d/pbs restart```

Now you can test if the jobs are running or not by simply invoking:

```echo "sleep 60" | qsub``` and then seeing using ```qstat -a``` if the job is submitted or not.

Thus we have successfully automated the configuration of  a virtual PBS cluster using tools like pdsh and shell scripts.
