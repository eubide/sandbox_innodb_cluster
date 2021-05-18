# -*- mode: ruby -*-
# vi: set ft=ruby :

# base of ips that will be user
base_ip="192.168.21."

# first ip to be used
first_ip=60

# the number of nodes
number_of_slaves = 3

# create an array to store the list of ips
ips = [ "#{base_ip}#{first_ip}" ]

# build the list of ips for each node and gcomm address
(1..number_of_slaves).each do |a|
  first_ip += 1
  ips.push("#{base_ip}#{first_ip}")
end

Vagrant.configure(2) do |config|

  (1..number_of_slaves).each do |i|
  
    config.vm.define "node#{i}" do |node|
      node.vm.box = "centos/7"
      node.vm.host_name = "node#{i}"
      node.vm.network "private_network", ip:ips[i]
      # node.vm.network "forwarded_port", guest: 3306, host: 3306+#{i}
      node.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "512"]
        vb.customize ["modifyvm", :id, "--cpus", "1"]
      end

      node.vm.provision :shell do |s|
        s.path = "provision_node.sh"
        s.args = [i, ips[i], ips[1]]
      end

    end
  end

  config.vm.define "manager" do |manager|
    manager.vm.box = "centos/7"
    manager.vm.host_name = "manager"
    manager.vm.network "private_network", ip:ips[0]
    manager.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "256"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end

    # remove the first ip from ips (manager ip)
    ips.delete_at(0)
    manager.vm.provision :shell do |s|
      s.path = "provision_manager.sh"
      s.args = ips
    end
  end

end
