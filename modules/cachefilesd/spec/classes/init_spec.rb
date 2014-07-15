require 'spec_helper'
describe 'cachefilesd' do
  
  describe 'with default values for all parameters' do
    let(:facts) { { :osfamily => 'RedHat' } }
    
    it { should contain_class('cachefilesd') }
    
    it {
      should contain_file('cachefilesd_config_file').with({
        'ensure'  => 'file',
        'path'    => '/etc/cachefilesd.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }
    
    it {
      should contain_file('cachefilesd_config_file').with_content("#This file maintained by puppet, do not edit.

dir /var/cache/fscache
tag nfscache
culltable 12

# brun and frun represent the percent of free space (blocks) and free files available in the
# filesystem the cache resides on required for cachefilesd to run freely. (no culling, files
# added as accessed)

brun 10%
frun 10%

# bcull and fcull represent the percent free on the file system at which point cachefilesd
# will start culling the cache (deleteing files)

bcull 7%
fcull 7%

# bstop and fstop represent the percent free on the file system at which point cachefilesd will
# stop writing new files. It will resume writes only after the free space has risen to the
# ammount specified in brun and frun.

bstop 3%
fstop 3%

secctx system_u:system_r:cachefiles_kernel_t:s0
")
    }
  end 
end  