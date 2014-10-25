# tomcat::setup defines the deploy stage of Tomcat installation
define tomcat::deploy (
  $war_name           = undef,
  $war_versioned      = undef,
  $war_version        = undef,
  $deploy_path        = undef,
  $context            = undef,
  $symbolic_link      = undef,
  $external_conf      = undef,
  $external_dir       = undef,
  $external_conf_path = undef,
  $family             = undef,
  $update_version     = undef,
  $installdir         = undef,
  $tmpdir             = undef,
  $hot_deploy         = undef,
  $as_service         = undef,
  $direct_restart     = undef) {
  $extension = ".war"
  $tomcat = "apache-tomcat"
  $default_deploy = "/webapps/"

  # Validate parameters presence
  if ($war_name == undef) {
    fail('war name parameter must be set')
  }

  if ($family == undef) {
    fail('family parameter must be set')
  }

  if ($update_version == undef) {
    fail('update version parameter must be set')
  }
  
  if ($hot_deploy == undef) {
    fail('hot deploy parameter must be set')
  }
  
  if (($hot_deploy != 'yes') and ($hot_deploy != 'no')) {
    fail('hot deploy parameter must have value "yes" or "no"')
  }

  if ($war_versioned == undef) {
    notify { 'War versioned not specified, setting War versioned to no': }
    $defined_war_versioned = 'no'
  } else {
    $defined_war_versioned = $war_versioned
  }

  if ($defined_war_versioned == 'yes') {
    if ($war_version == undef) {
      fail('war version parameter must be set, if war versioned parameter is set to yes')
    }
  }
  
  if (($hot_deploy == "yes") and ($direct_restart != undef)){
     notify { "direct restart parameter setted, but hot deploy parameter is equal to no. Ignoring direct restart parameter.": }
  }

  if ($defined_war_versioned == 'no') {
    if ($war_version != undef) {
      notify { "war version parameter setted, but war versioned parameter is set to no. Ignoring war version.": }
    }
  }
  
  if ($as_service == undef) {
    $defined_as_service = "no"
  } else {
    $defined_as_service = $as_service
  }
  
  if ($direct_restart == undef) {
    $restart = "yes"
  } else {
    $restart = $direct_restart
  }

  if ($deploy_path == undef) {
    notify { 'Deploy path not specified, setting default deploy folder /webapps/': }
    $defined_deploy_path = $default_deploy
  } else {
    $defined_deploy_path = $deploy_path
  }

  if ($installdir == undef) {
    notify { 'Install folder not specified, setting default install folder /opt/': }
    $defined_installdir = '/opt/'
  } else {
    $defined_installdir = $installdir
  }

  if ($tmpdir == undef) {
    notify { 'Temp folder not specified, setting default install folder /tmp/': }
    $defined_tmpdir = '/tmp/'
  } else {
    $defined_tmpdir = $tmpdir
  }

  if (($defined_deploy_path == $default_deploy) and ($context != undef)) {
    notify { 'deploy path is default, context will not be considered': }
  }

  if (($defined_deploy_path != $default_deploy) and ($context == undef)) {
    fail('context parameter must be set if deploy path is different from /webapps/')
  }
  
  if (($symbolic_link == undef)){
    notify { 'Symbolic link not specified, setting default Symbolic link value to no': }
    $defined_symbolic_link = 'no'
  } else {
    $defined_symbolic_link = $symbolic_link
  }
  
  if (($symbolic_link == 'yes') and ($war_versioned == 'no')){
    notify { 'Symbolic link setted to yes, but deploying package is not versioned. Symbolic link will be ignored': }
  }

  if ($external_conf == undef) {
    notify { 'External conf not specified, setting default External conf value to no': }
    $defined_ext_conf = 'no'
  } else {
    $defined_ext_conf = $external_conf
  }

  if (($defined_ext_conf == 'yes')) {
    if ($external_conf_path == undef) {
      notify { 'External conf path not specified, setting default External conf path value to /conf/': }
      $defined_ext_conf_path = '/conf/'
    } else {
      $defined_ext_conf_path = $external_conf_path
    }

    if ($external_dir == undef) {
      fail('external dir parameter must be set if external_conf is equal to yes')
    }
  }
  
  
  exec { 'sleep': command => "sleep 10", }
  
  if ($hot_deploy == "no"){
    if ($as_service == "yes"){
      exec { "stop_tomcat_as_service":
        command => "service tomcat stop",
        onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
        require => Exec["sleep"]
        }
    } else {
		  exec { "stop_tomcat":
		    command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/shutdown.sh",
		    onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
        require => Exec["sleep"]}
		  }
    }

  if ($defined_ext_conf == 'yes') {
    exec { 'create_conf_path':
      command => "mkdir -p ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}",
      alias   => "app_conf_path"
    }

    file { "${defined_tmpdir}${external_dir}":
      ensure  => directory,
      source  => "puppet:///modules/tomcat/${external_dir}",
      require => Exec[app_conf_path],
      alias   => "tmp_conf",
      recurse => true
    }

    exec { 'move_conf':
      command => "mv ${defined_tmpdir}${external_dir} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}",
      require => [File[tmp_conf], Exec[app_conf_path]],
      alias   => "move_conf"
    }

    exec { 'clean_conf':
      command   => "rm -rf ${defined_tmpdir}${external_dir}",
      require   => Exec[move_conf],
      logoutput => "false"
    }
  }

  if ($defined_deploy_path == $default_deploy) {
    if ($defined_war_versioned == 'no') {
      file { "${defined_tmpdir}${war_name}${extension}":
        ensure => present,
        source => "puppet:///modules/tomcat/${war_name}${extension}",
        alias  => "tmp_war"
      }

      exec { 'move_war':
        command => "mv ${defined_tmpdir}${war_name}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => File[tmp_war],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
        alias   => "move_war"
      }

      exec { 'clean_war':
        command   => "rm -rf ${defined_tmpdir}${war_name}${extension}",
        require   => Exec[move_war],
        logoutput => "false"
      }

    } elsif ($defined_war_versioned == 'yes') {
      file { "${defined_tmpdir}${war_name}-${war_version}${extension}":
        ensure => present,
        source => "puppet:///modules/tomcat/${war_name}-${war_version}${extension}",
        alias  => "tmp_war"
      }

      exec { 'move_war':
        command => "mv ${defined_tmpdir}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => File[tmp_war],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
        alias   => "move_war"
      }

      exec { 'clean_war':
        command   => "rm -rf ${defined_tmpdir}${war_name}-${war_version}${extension}",
        require   => Exec[move_war],
        logoutput => "false"
      }
    }
  } else {
    exec { 'create_alternative_deploy_path':
      command => "mkdir ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
      unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
      alias   => "alternative_deploy_path"
    }

    exec { 'create_app_context_path':
      command => "mkdir -p ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}",
      alias   => "app_context_path"
    }

    file { "app_context_xml":
      path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}.xml",
      owner   => 'root',
      group   => 'root',
      require => [Exec[app_context_path]],
      mode    => '0644',
      content => template("tomcat/appcontext-${family}.erb")
    }

    if ($defined_war_versioned == 'no') {
      file { "${defined_tmpdir}${war_name}${extension}":
        ensure  => present,
        source  => "puppet:///modules/tomcat/${war_name}${extension}",
        require => Exec[alternative_deploy_path],
        alias   => "tmp_war"
      }

      exec { 'move_war':
        command => "mv ${defined_tmpdir}${war_name}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => [File[tmp_war], Exec[alternative_deploy_path], File["app_context_xml"]],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
        alias   => "move_war"
      } 

      exec { 'clean_war':
        command   => "rm -rf ${defined_tmpdir}${war_name}${extension}",
        require   => Exec[move_war],
        logoutput => "false"
      }

    } elsif ($defined_war_versioned == 'yes') {
      file { "${defined_tmpdir}${war_name}-${war_version}${extension}":
        ensure => present,
        source => "puppet:///modules/tomcat/${war_name}-${war_version}${extension}",
        alias  => "tmp_war"
      }

      exec { 'move_war':
        command => "mv ${defined_tmpdir}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => [File[tmp_war], Exec[alternative_deploy_path], File["app_context_xml"]],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
        alias   => "move_war"
      }
      
      if ($defined_symbolic_link == 'yes'){
	      exec { 'create_ln':
	        command => "ln -s ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
	        require => [Exec[move_war],Exec[alternative_deploy_path], File["app_context_xml"]],
	        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
	        alias   => "create_ln"
	      }
      }

      exec { 'clean_war':
        command   => "rm -rf ${defined_tmpdir}${war_name}-${war_version}${extension}",
        require   => Exec[move_war],
        logoutput => "false"
      }
    }
  }

  if ($hot_deploy == "no"){ 
	  if ($defined_as_service == 'no') {
	    if ($restart == 'yes') {
	      exec { 'restart':
	        command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
	        unless  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
	        require => [Exec["stop_tomcat"],Exec[move_war]]
	       }
	     }
	  } elsif ($defined_as_service == "yes") {
	    if ($restart == 'yes') {
	      exec { "restart_tomcat":
	        command => "service tomcat start",
	        require => [Exec["stop_tomcat_as_service"],Exec[move_war]],
	        unless => "ls /etc/init.d/tomcat"
	      }
	    }
	  }
 }
}