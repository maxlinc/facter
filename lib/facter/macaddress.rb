       Facter.add(:macaddress) do
            confine :operatingsystem => %w{Solaris Linux Fedora RedHat CentOS SuSE Debian Gentoo}
            setcode do
                ether = []
                output = %x{/sbin/ifconfig -a}
                output.each {|s|
                             ether.push($1) if s =~ /(?:ether|HWaddr) (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
                            }
                ether[0]
            end
        end

        Facter.add(:macaddress) do
            confine :operatingsystem => %w{FreeBSD OpenBSD}
            setcode do
            ether = []
                output = %x{/sbin/ifconfig}
                output.each {|s|
                             if s =~ /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                                  ether.push($1)
                             end
                            }
                ether[0]
            end
        end

        Facter.add(:macaddress) do
            confine :kernel => :darwin
            setcode do
                ether = nil
                output = %x{/sbin/ifconfig}

                output.split(/^\S/).each { |str|
                    if str =~ /10baseT/ # we're wired
                        str =~ /ether (\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
                        ether = $1
                    end
                }

                ether
            end
        end
        
        Facter.add(:macaddress) do
            confine :kernel => %w{AIX}
            setcode do
                ether = []
                ip = nil
                output = %x{/usr/sbin/ifconfig -a}
                output.each { |str|
                    if str =~ /([a-z]+\d+): flags=/
                        devname = $1
                        unless devname =~ /lo0/
                           output2 = %x{/usr/bin/entstat #{devname}}
                           output2.each { |str2|
                                       if str2 =~ /^Hardware Address: (\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
                                          ether.push($1)
                                       end
                                       }
                        end
                    end
                }
                ether[0]
            end
        end
