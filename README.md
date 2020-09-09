
# Capstone Project - Setting up a Cloud System

> 

_Note:_ If any error occurs, there are many ways to debug. It's possible to go
through the logs directory for ERRORS that may come up.
```
/var/logs/<service>
```

# Preliminary Steps - Environment

Most of the items are based on the installation instruction in the OpenStack Ocata Page linked below:

[OpenStack Official Documentation ( Ocata )](https://docs.openstack.org/ocata/install-guide-ubuntu/environment-ntp-controller.html)

## Setup Shared folder with vbox

Install vbox additions then mount

```
mkdir ~/GuestShared
sudo mount -t vboxsf -o uid=1000,gid=1000,rw GuestShared ~/GuestShared
```


## Hostname and hosts file
- `/etc/hostname` Change the file to the hostname of the node
- `/etc/hosts` Change hosts to point into particular nodes in 

Change the interfaces in `network/interfaces` within each folder. Refer to the mapping below:

```
controller 	10.x.x.10
compute 	10.x.x.20
store 		10.x.x.30
network 	10.x.x.40

```

## Network Architecture

3 adapters will be used in the system configuration: Data, Management and External NAT network to access the internet as setup below:

```
Management	10.10.10.x
Data		10.20.20.x
NatNetwork	10.0.2.x
```

## Chrony - NTP 

NTP is used to synchronize all time related within the nodes. We are setting Chrony on controller and syncing the rest to the controller node.

Controller + Other nodes

[Source](https://docs.openstack.org/ocata/install-guide-ubuntu/environment-ntp-controller.html)

## Add OpenStack Sources

Refer to `addSources` file

## Install SQL Services using MySQL

Refer to `MySQL` Folder

## Install message queue with RabbitMq

OpenStack uses a messaging queue for services to coordinate with each other. There are many choices available but we will be using RabbitMQ

Check folder `RabbitMQ`

## Install Token Caching with Memcached

Memcached is used to cache tokens whenever Keystone tries to authenticate a user.

Configure memcached on the controller. Find the flag `-l` and add the controller on management network.

```
-l 10.10.10.10
```
Restart the memcached

```
sudo service memcached restart
```

Check folder `Memcached`


# Identity - KeyStone

Check folder `Keystone`

After running the `01` install script, do the following:
Add/change in file `/etc/keystone/keystone.conf`

```
[database]
# ...
connection = mysql+pymysql://keystone:letmein@controller/keystone
```

```
[token]
# ...
provider = fernet
```

Run `02` install script

## Configure the apache config

Set the servername in `/etc/apache2/apache2.conf` on top of the page like so:

```
ServerName controller
```

## Test scripts

Check Keystone/testing folder.

Execute the command
```
. admin-openrc
openstack token issue
```

Try the demo as well

# Glance Imaging Service

Sets up the system as a repository of images that is stored as a `file` in the default directory `/var/lib/glance/images/` 

Check `Glance` folder 

Run `installGlance`

Edit the file `/etc/glance/glance-api.conf` and add the following

```
[database]
# ...
connection = mysql+pymysql://glance:letmein@controller/glance


[keystone_authtoken]
# ...
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = letmein

[paste_deploy]
# ...
flavor = keystone


[glance_store]
# ...
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```

There's additional things to do. Refer to [the official documentation](https://docs.openstack.org/ocata/install-guide-ubuntu/glance-install.html)

After that, do `postInstallGlance`
If error comes up regarding locale, run 

```
export LC_ALL=en_US.UTF-8
```

# Compute Service ( Nova )

## Controller

Check install instructions inside ComputeConf in controller and Compute in compute node
Again, after running `installComputeConf`, there will still be addition configurations for it. Refer to the [official documentations](https://docs.openstack.org/ocata/install-guide-ubuntu/nova-controller-install.html)

## Compute 

Check compute folder inside compute node.

After installing using the `installNova`, continue configuration from the [official documentations](https://docs.openstack.org/ocata/install-guide-ubuntu/nova-compute-install.html)

# Networking ( Neutron)

Networking is one of the challenging tasks for there are 2 choices of which the installation can continue. The networking module can be set aside in its own node in the system. However, the decided option to do is to put them inside the controller node as the project itself is not complicated enough to balance the load of the controller.

## Option 1 Networking

/// EDIT HERE

## Option 2 Networking

This is the chosen option as it gives enough flexibility on the tenant users to create their own networking configuration that suits their needs. Compared to the first option, this is a more powerful way of managing networking as it extends beyond what the first option offers, which is simply adding the instance in the network and that's about it. Option 2 adds a layer of functionality that will almost always be needed.


## Installation

### Controller Node

Refer to the `Networking` folder (controller node)

After the `installNetworking` script is done, refer to the official installation on the configurations.

Since Option 2 is used, option 2 configuration should be done depending on the instructions writted on the official documentation

### Compute Node

Refer to the `Networking` folder. 
Since Option 2 is used, option 2 configuration should be done depending on the instructions writted on the official documentation

# Launching an instance

Setup provider network first, then selfservice network. After, create a router using demo account

## Verification

Run `ip netns` with adminrc to  show possible namespaces

Trying to ping the router needs to have the namespace of the ip to be the dhcp of the router. And so, a command like below is to be ran to execute the ping command properly:

```
sudo ip netns exec qdhcp-22d0f59b-71ec-47c3-b8c2-f3b883eeb8c4 ping 203.0.113.109
```

The address `203.0.113.109` of the router is listed from the command 

```
neutron router-port-list router
```

## Create flavor like a container

m1.nano flavor

virtual cpu = 1
ram = 64
disks = 1
name: m1.nano

Launching the instance will need the selfservice net id which can be taken from the command 
```
openstack network list
```

# Things to keep in mind

When restarting and trying to access the instances, make sure that the network
services and servers are active. To check, 

```
openstack server list
```

It shows the servers that outputs like so:

| ID                                   | Name                 | Status | Networks                | Image Name |
|--------------------------------------|:--------------------:|:------:|-------------------------|------------|
| 1c376f83-bd1a-410d-9978-0f5d2c676d7b | provider-instance    | BUILD  |                         | cirros     |
| ea9e26ff-0bb1-43bd-94f8-0eeac609a6f2 | selfservice-instance | ACTIVE | selfservice=172.16.1.11 | cirros     |

Make sure that it's `ACTIVE` before going beyond. The names above are the name
of the instances. Incase the `STATUS` is SHUTOFF, start them by doing the
commands below:

```bash
nova start <name> 

## i.e.
## nova start selfservice-instance
```
List the servers again and check if it's active. It may take awhile.

Check `nova` services. Restart the services if any error occurs when accessing
the vnc

