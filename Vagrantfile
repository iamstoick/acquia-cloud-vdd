# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  host = RbConfig::CONFIG['host_os']

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Load config JSON
  vm_config_path = File.expand_path(File.dirname(__FILE__)) + "/conf/config.json"
  vm_config = JSON.parse(File.read(vm_config_path))

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = vm_config["name"]

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = vm_config["box_url"]

  # To be ale to use this snippet you must have "vagrant-cachier" installed.
  # Please refer to the doc about installing Vagrant plugin.
  # https://docs.vagrantup.com/v2/plugins/usage.html
  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync
    config.cache.synced_folder_opts = {
      type: :nfs,
      # The nolock option can be useful for an NFSv3 client that wants to avoid the
      # NLM sideband protocol. Without this option, apt-get might hang if it tries
      # to lock files needed for /var/cache/* operations. All of this can be avoided
      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
    # For more information please check http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: vm_config["ports"]["http_guest_varnish"],
    host: vm_config["ports"]["http_host_varnish"]
  config.vm.network :forwarded_port, guest: vm_config["ports"]["https_guest"],
    host: vm_config["ports"]["https_host"]
  config.vm.network :forwarded_port, guest: vm_config["ports"]["http_guest_apache"],
    host: vm_config["ports"]["http_host_apache"]

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: vm_config["ip"]

  # VM hostname.
  config.hostsupdater.remove_on_suspend = true
  config.vm.hostname = vm_config["hostname"]

  # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may be
  # required to enter a password for Vagrant to access your hosts file.
  if defined? VagrantPlugins::HostsUpdater
    # Capture the paths to all hostname
    if !vm_config['aliases'].empty?
      config.hostsupdater.aliases = vm_config['aliases'].values
    end
  end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  if vm_config["nfs"] == true
    # Set no_root_squash to prevent NFS permissions errors on Linux during
    # provisioning, and maproot=0:0 to correctly map the guest root user.
    if (/darwin/ =~ host) != nil
      config.vm.synced_folder vm_config["synced_folder"]["host_path"],
        vm_config["synced_folder"]["guest_path"],
        type: "nfs", :bsd__nfs_options => ["maproot=0:0"]
    else
      config.vm.synced_folder vm_config["synced_folder"]["host_path"],
        vm_config["synced_folder"]["guest_path"],
        # type: "nfs", :linux__nfs_options => ["rw", "sync","no_root_squash", "subtree_check"]
        # the fsc is for cachedfilesd
        type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc']
    end
  else
    config.vm.synced_folder vm_config["synced_folder"]["host_path"],
      vm_config["synced_folder"]["guest_path"], type: "smb"
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.

  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    vb.gui = false
    vb.name = vm_config['vm_name']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      # Default to one to make sure that VT-x error will not trigger. Set to two
      # when your machine is has VT-x enabled
      cpus = 1
      mem = 1024
    end

    vb.customize ["modifyvm", :id, "--memory", mem]
    vb.customize ["modifyvm", :id, "--cpus", cpus]
  end

  config.vm.provision :puppet, :facter => { "host_uid" => Process.uid, "host_gid" => Process.gid } do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.module_path = ["modules", "sites", "env"]
    # puppet.options = "--graph"
  end
end
