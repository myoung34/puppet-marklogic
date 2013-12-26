require 'facter'

if Facter.value(:kernel) == 'Linux'
  Facter.add("ec2_root_partition") do
    setcode do
      mounts = Facter::Util::Resolution.exec("/bin/mount").split("\n")
      root_mount = mounts.select { |mount_line| mount_line =~ /on \/ type/ }[0]
      root_mount.gsub!(/^(\/dev\/.+?) on .*/,'\1')
      #root_mount => "xvde1"
    end
  end
end
