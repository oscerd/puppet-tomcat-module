define tomcat::undeploy (
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

  if ($war_versioned == undef) {
    notify { 'War versioned not specified, setting War versioned to no': }
    $defined_war_versioned = 'no'
  } else {
    $defined_war_versioned = $war_versioned
  }


  if ($as_service == undef) {
    $defined_as_service = "no"
  } else {
    $defined_as_service = $as_service
  }
  
  if ($direct_restart == undef) {
    $restart = "no"
  } else {
    $restart = $direct_restart
  }
  
  if ($defined_war_versioned == 'yes') {
    if ($war_version == undef) {
      fail('war version parameter must be set, if war versioned parameter is set to yes')
    }
  }

  if ($defined_war_versioned == 'no') {
    if ($war_version != undef) {
      notify { "war version parameter setted, but war versioned parameter value is equal to no. Ignoring war version.": }
    }
  }

  if ($deploy_path == undef) {
    notify { 'Deploy path not specified, setting to default deploy folder /webapps/': }
    $defined_deploy_path = $default_deploy
  } else {
    $defined_deploy_path = $deploy_path
  }

  if ($installdir == undef) {
    notify { 'Install folder not specified, setting to default install folder /opt/': }
    $defined_installdir = '/opt/'
  } else {
    $defined_installdir = $installdir
  }

  if (($defined_deploy_path == $default_deploy) and ($context != undef)) {
    notify { 'deploy path is default so context will not be considered': }
  }

  if (($defined_deploy_path != $default_deploy) and ($context == undef)) {
    fail('context parameter must be set if deploy path is different from /webapps/')
  }

  if (($symbolic_link == undef)) {
    notify { 'Symbolic link not specified, setting default Symbolic link to no': }
    $defined_symbolic_link = 'no'
  } else {
    $defined_symbolic_link = $symbolic_link
  }

  if (($symbolic_link == 'yes') and ($war_versioned == 'no')) {
    notify { 'Symbolic link setted to yes, but deploying package is not versioned so symbolic link will be ignored': }
  }

  if ($external_conf == undef) {
    notify { 'External conf not specified, setting default External conf value to no': }
    $defined_ext_conf = 'no'
  } else {
    $defined_ext_conf = $external_conf
  }

  if (($defined_ext_conf == 'yes')) {
    if ($external_conf_path == undef) {
      notify { 'External conf path not specified, setting default External conf path to /conf/': }
      $defined_ext_conf_path = '/conf/'
    } else {
      $defined_ext_conf_path = $external_conf_path
    }

    if ($external_dir == undef) {
      fail('external dir parameter must be set if external_conf is equal to yes')
    }
  }

  exec { 'sleep': command => "sleep 10", }
  
  if ($defined_as_service == "no") {
	  exec { 'shutdown':
	    command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/shutdown.sh",
	    onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
	    require => Exec["sleep"]
	  }  
  } else {
    exec { 'shutdown':
      command => "service tomcat stop",
      onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
      require => Exec["sleep"]
    } 
  }

  if ($defined_deploy_path == $default_deploy) {
    if ($defined_war_versioned == 'no') {
      exec { 'delete_package':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
        require => [Exec["sleep"], Exec["shutdown"]],
        alias => "delete_package"
      }

      exec { 'delete_folder':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package]],
        alias => "delete_folder"
      }
      
      if ($defined_ext_conf == 'yes') {
	      exec { 'delete_conf':
	        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
	        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder]],
	        alias => "delete_conf"
	      }
      }
    } elsif ($defined_war_versioned == 'yes') {
      exec { 'delete_package':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}${extension}",
        require => [Exec["sleep"], Exec["shutdown"]],
        alias => "delete_package"
      }

      exec { 'delete_folder':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
        require => [Exec["sleep"], Exec["shutdown"], Exec[delete_package]],
        alias => "delete_folder"
      }
      
      if ($defined_ext_conf == 'yes') {
        exec { 'delete_conf':
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder]],
          alias => "delete_conf"
        }
      }
    }
  } else {
    if ($defined_war_versioned == 'no') {
      exec { 'delete_package':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
        require => [Exec["sleep"], Exec["shutdown"]],
        alias => "delete_package"
      }

      exec { 'delete_folder':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${default_deploy}${context}",
        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package]],
        alias => "delete_folder"
      }
      
      exec { 'delete_context_file':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}.xml",
        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder]],
        alias => "delete_context_file"
      }
      
      if ($defined_ext_conf == 'yes') {
        exec { 'delete_conf':
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder], Exec[delete_context_file]],
          alias => "delete_conf"
        }
      }
      
    } elsif ($defined_war_versioned == 'yes') {
      exec { 'delete_package':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}${extension}",
        require => [Exec["sleep"], Exec["shutdown"]],
        alias => "delete_package"
      }

      exec { 'delete_folder':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${default_deploy}${context}",
        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package]],
        alias => "delete_folder"
      }
      
      exec { 'delete_context_file':
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}.xml",
        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder]],
        alias => "delete_context_file"
      }
      
      if ($defined_ext_conf == 'yes') {
        exec { 'delete_conf':
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder], Exec[delete_context_file]],
          alias => "delete_conf"
        }
      }
      
      if ($symbolic_link == 'yes') {
        exec { 'delete_symbolic_link':
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
          require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder], Exec[delete_context_file]],
          alias => "delete_symbolic_link"
        }
      }
    }
  }
  
  if ($defined_as_service == 'no') {
	  if ($restart == 'yes') {
		  exec { 'restart':
		    command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
		    onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
		    require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder]]
		   }
	   }
  } elsif ($defined_as_service == "yes") {
    if ($restart == 'yes') {
      exec { "restart_tomcat":
        command => "service tomcat start",
        require => [Exec["sleep"], Exec["shutdown"],Exec[delete_package],Exec[delete_folder]],
        unless => "ls /etc/init.d/tomcat"
      }
    }
  }
}