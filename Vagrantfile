Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.provision 'shell', privileged: false, inline: <<-EOF
    export DEBIAN_FRONTEND=noninteractive

    # ruby 2.3
    sudo apt-add-repository ppa:brightbox/ruby-ng
    sudo apt-get update
    sudo apt-get install -y ruby2.3
    sudo gem install bundler

    # Gemfile
    cd /vagrant
    bundle install
  EOF
end
