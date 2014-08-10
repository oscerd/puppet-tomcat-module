Puppet Tomcat Module
========================

Introduction
-----------------

This module install Tomcat with puppet

Installation
-----------------

Clone this repository in a tomcat directory in your puppet module directory

	git clone https://github.com/ancosen/puppet-tomcat-module tomcat

Usage
-----------------

If you include the tomcat::setup class by setting source_mode to `web` the module will download the package, extract it and move it 
in a specific directory. If you set the source_mode `local` the tomcat package must be place in `/tomcat/files/` 
folder. The module will do the same operations without download the package. For more information about the parameters definition see [Parameters](#Parameters)

```puppet
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
```

It's important to define a global search path for the `exec` resource to make module work. 
This should usually be placed in `manifests/site.pp`. It is also important to make sure `unzip` and `tar` command 
are installed on the target system:

```puppet
	Exec {
	  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
	}

	package { 'tar':
	  ensure => installed
	}

	package { 'unzip':
	  ensure => installed
	}
```

Parameters
-----------------

The Puppet Tomcat module use the following parameters in his setup

*  __Family__: Possible values of Apache Tomcat version _6_, _7_, _8_ 
*  __Update Version__: The update version
*  __Extension__: The file extension, possible values _.zip_ and _.tar.gz_
*  __Source Mode__: The source mode, possible values _local_ and _web_. Setting _local_ make module search the package in `tomcat/files/` folder. Setting mode _web_ make the module download the specified package
*  __Install Directory__: The directory where the Apache Tomcat will be installed (default is `/opt/`)
*  __Temp Directory__: The directory where the Apache Tomcat package will be extracted (default is `/tmp/`)
*  __Install Mode__: The installation mode, possible values _clean_ and _custom_. With install mode _clean_ the module will only install Apache Tomcat, while with install mode _custom_ the module will install Apache Tomcat with a customizable version of `server.xml`
*  __Data Source__: Define the data source's presence, possible values _yes_ and _no_. If the data source value is _yes_ (and the installation mode value is _custom_ ) then the module will add data source section in `server.xml` and `context.xml`

Customization
-----------------

When using the _custom_ installation mode, the module will use the template `templates/serverxml.erb` to build a `server.xml` custom file. The module will use the following parameters (listed in tomcat::params class):

```puppet
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
```

When using the _custom_ installation mode with data source value equal to _yes_, the module will customize `conf/server.xml` and `conf/context.xml` (by using `templates/serverxml.erb` and `templates/context.erb` templates) to build a data source. The parameters related to data source are the following (listed in tomcat::data_source class):

```puppet
	# Set Name
	$ds_resource_name = "jdbc/ExampleDB"

	# Set MaxActive
	$ds_max_active = "100"

	# Set MaxIdle
	$ds_max_idle = "20"

	# Set MaxWait
	$ds_max_wait = "10000"

	# Set username
	$ds_username = "username"

	# Set password
	$ds_password = "password"

	# Set driver class name
	$ds_driver_class_name = "oracle.jdbc.OracleDriver"

	# Url variable
	$ds_driver = "jdbc"
	$ds_dbms = "oracle"
	$ds_host = "192.168.52.128"
	$ds_port = "1521"
	$ds_service = "example"

	# Builded url
	$ds_url = "${ds_driver}:${ds_dbms}:thin:@${ds_host}:${ds_port}/${ds_service}"
```

Testing
-----------------

The Puppet tomcat module has been tested on the following Operating Systems: 

1. CentOS 6.5 x64
1. Debian 7.5 x64
1. Fedora 20.0 x86_64
1. Ubuntu 14.04 x64

Contributing
-----------------

Feel free to contribute by testing, opening issues and adding/changing code

License
-----------------

Copyright 2014 Oscerd and contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
