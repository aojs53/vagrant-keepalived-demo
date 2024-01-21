# vagrant-keepalived-demo

## What's this

This is a demo environment to demonstrate to distribute ssh and ftp access by keepalived on vagrant.

There are 5 servers in this environment.

| Role           | hostname | comment                          |
| -------------  | -------- | -------------------------------- |
| VIP            | lvs      | IP address handled by keepalived |
| lvs #1         | lvs1     | primary keepalived server        |
| lvs #2         | lvs2     | secondary keepalived  server     |
| real server #1 | s1       | server to accept client access   |
| real server #2 | s2       | server to accept client access   |
| client         | cl       | client to test access.           |


## How to use

### clone this repo

```
$ https://github.com/aojs53/vagrant-keepalived-demo.git 

$ cd vagrant-keepalived-demo
```


### Build this environment

```
your pc $ vagrant up
```


### Access to client

```
your pc $ vagrant ssh cl
```


### Test access to VIP

#### preparation

```
vagrant@cl $ sudo mount /vagrant
vagrant@cl $ cd /vagrant
```

#### Test ssh access

```
vagrant@cl $ ./test_ssh.sh
```

You will be able to observe ssh access are distibuted to s1 and s2.


#### Test ftp access

```
vagrant@cl $ ./test_ftp.sh
```

This script tests upload and download by both ACTIVE mode and PASSIVE mode.
Thease ftp access will not be distributed accross the two servers,
but wll be continue to access one server.
These are normal operation.
(Another client will access to another server.)

