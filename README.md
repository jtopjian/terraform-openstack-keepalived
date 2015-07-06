# Using Terraform to Deploy keepalived

This repository will deploy a two-node keepalived/vrrp cluster inside OpenStack. The nodes will be able to failover a floating IP from one node to the other.

## Instructions

* Add your OpenStack credentials to `scripts/openrc`
* Generate an SSH key:

```shell
$ ssh-keygen -f key/id_rsa
```

* Deploy:

```shell
$ terraform plan
$ terraform apply
```

## Test

You can watch the failover in action by doing the following in one terminal:

```shell
$ watch "nova list | grep keepalived"
```

Then do the following in another terminal:

```shell
$ nova stop keepalived-1
```

Bring `keepalived-1` back up and watch the IP fail back:

```shell
$ nova start keepalived-1
```

## Limitations

This is just a demo and should not be used for production. The `keepalived.conf` file is very sparse and you'd probably want to add more options to it. In addition, this demo only accounts for two servers at the time of deployment. If you wanted to add more servers or have more of a dynamic environment, you'll have to use something like etcd or Consul in parallel to this.
