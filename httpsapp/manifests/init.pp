class  httpsapp(
  $keystore_path = "/root/.keystore",
  $keystore_pass = 'changeit'  
){
    package { 'openssl' :
      ensure => installed,
    }

    java::oracle { 'jdk8' :
        ensure  => 'present',
        version => '8',
        java_se => 'jdk',
        require => Package['openssl'],
    }

    tomcat::install {"/opt/tomcat8":
        source_url => "http://www.webhostingjams.com/mirror/apache/tomcat/tomcat-8/v8.5.4/bin/apache-tomcat-8.5.4.tar.gz",
        require    => Java::Oracle['jdk8'],
    }

    firewall {'006 Allow inbound SSH (v6)':
        dport    => 8443 ,
        proto    => tcp,
        action   => accept,
        provider => 'iptables',
        require  => Tomcat::Install['/opt/tomcat8'],
    }

    file { 'webapp' :
        ensure  => directory,
        path    => '/opt/tomcat8/webapps/helloworld',
        mode    => '0777',
        require => Firewall["006 Allow inbound SSH (v6)"],
    }

    file { 'helloworldhtml' :
        ensure  => present,
        path    => '/opt/tomcat8/webapps/helloworld/index.html',
        source  => "puppet:///modules/httpsapp/index.html",
        mode    => '0777',
        require => File["webapp"],
    }
    #file{"server_xml":
    #    path    => "/opt/tomcat8/conf/server.xml",
    #   ensure  => present,
    #   mode    => "0777",
    #   require => File["helloworldhtml"],
    #   content => template("httpsapp/server.xml.erb")
    #}
   #file{"web_xml":
   #  path    => "/opt/tomcat8/conf/web.xml",
   #  ensure  => present,
   #  source  => "puppet:///modules/httpsapp/web.xml",
   #  require => File["server_xml"],
   #  mode    => "0777",
   #}
   #java_ks{'puppet:keystore':
   # ensure       => latest,
   # certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
   # target       => "$keystore_path",
   # password     => "$keystore_pass",
   # trustcacerts => true,
   # require      => File["web_xml"]
   #}
  exec{"start_tomcat":
     path    => "$::path",
     cwd     => "/opt/tomcat8/bin",
     command => "/opt/tomcat8/bin/startup.sh \&",
     # require => Java_ks["puppet:keystore"]
  }
}
include httpsapp
