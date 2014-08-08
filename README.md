Puppet Tomcat Module
========================

## <a name='TOC'>Table of Contents</a>

  1. [Introduction](#Introduction)
  1. [Installation](#Installation)
  1. [Usage](#Usage)
  1. [Parameters](#Parameters)
  1. [Customization](#Customization)
  1. [Testing](#Testing)
  1. [Contributing](#Contributing)

## <a name='Introduction'>Introduction</a>

This module install Tomcat with puppet

## <a name='Installation'>Installation</a>

Clone this repository in a tomcat directory in your puppet module directory

	git clone https://github.com/ancosen/puppet-tomcat-module tomcat

## <a name='Usage'>Usage</a>

If you include the tomcat::setup class by setting source_mode to `web` the module will download the package, extract it and move it 
in a specific directory. If you set the source_mode `local` the tomcat package must be place in `/tomcat/files/` 
folder. The module will do the same operations without download the package. For more information about the parameters definition see [Parameters](#Parameters)

	tomcat::setup { "tomcat":
	  family => "7",
	  update_version => "55",
	  extension => ".zip",
	  source_mode => "local",
	  installdir => "/opt/",
	  tmpdir => "/tmp/",
	  install_mode => "custom",
	  data_source => "yes"
	  }

It's important to define a global search path for the `exec` resource to make module work. 
This should usually be placed in `manifests/site.pp`. It is also important to make sure `unzip` and `tar` command 
are installed on the target system:

	Exec {
	  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
	}

	package { 'tar':
	  ensure => installed
	}

	package { 'unzip':
	  ensure => installed
	}

## <a name='Parameters'>Parameters</a>

The Puppet Tomcat module use the following parameters in his setup

*  __Family__: Possible values of Apache Tomcat version _6_, _7_, _8_ 
*  __Update Version__: The update version
*  __Extension__: The file extension, possible values _.zip_ and _.tar.gz_
*  __Source Mode__: The source mode, possible values _local_ and _web_. Setting _local_ make module search the package in `tomcat/files/` folder. Setting mode _web_ make the module download the specified package
*  __Install Directory__: The directory where the Apache Tomcat will be installed (default is `/opt/`)
*  __Temp Directory__: The directory where the Apache Tomcat package will be extracted (default is `/tmp/`)
*  __Install Mode__: The installation mode, possible values _clean_ and _custom_. With install mode _clean_ the module will only install Apache Tomcat, while with install mode _custom_ the module will install Apache Tomcat with a customizable version of `server.xml`
*  __Data Source__: Define the data source presence, possible values _yes_ and _no_. If the data source value is _yes_ (and the installation mode value is _custom_ ) then the module will add data source section in `server.xml` and `context.xml`

## <a name='Customization'>Customization</a>

When using the _custom_ installation mode, the module will use the template `templates/serverxml.erb` to build a `server.xml` custom file. The module will use the following parameters (liste in tomcat::params class):

	# Set http port in serverxml.erb
	$http_port = "8082"
		  
	# Set https port in serverxml.erb
	$https_port = "8083"
		  
	# Set ajp port in serverxml.erb
	$ajp_port = "8007"
		  
	# Set shutdown port in serverxml.erb
	$shutdown_port = "8001"
		  
	# Set connection timeout in http connector in serverxml.erb
	$http_connection_timeout = "20000"
		  
	# Set max threads in https connector in serverxml.erb
	$https_max_threads = "150"

## <a name='Testing'>Testing</a>

The Puppet tomcat module has been tested on the following Operating Systems: 

1. CentOS 6.5 x64
1. Debian 7.5 x64
1. Fedora 20.0 x86_64
1. Ubuntu 14.04 x64

## <a name='Contributing'>Contributing</a>

Feel free to contribute by testing, opening issues and adding/changing code
