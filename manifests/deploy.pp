# tomcat::setup defines the deploy stage of Tomcat installation
define tomcat::deploy (
  $war_name = undef,
  $war_versioned = undef,
  $war_version = undef,
  $deploy_path = undef,
  $context = undef,
  $family = undef,
  $update_version = undef,
  $installdir = undef,
  $tmpdir = undef
  ) { 
  
  $extension = ".war"
  $tomcat = "apache-tomcat"
  $default_deploy = "/webapps/"

  #Validate parameters presence   
  if ($war_name == undef) {
    fail('war name parameter must be set')
  } 
  
  if ($family == undef) {
    fail('family parameter must be set')
  }
  
  if ($update_version == undef) {
    fail('update version parameter must be set')
  }
 
  if ($war_versioned == undef){
    $defined_war_versioned ='no'
  } else {
    $defined_war_versioned = $war_versioned
  }  
  
  if ($defined_war_versioned == 'yes'){
	  if ($war_version == undef) {
	    fail('war version parameter must be set, if war versioned parameter is set to yes')
	  }
  }
  
  if ($defined_war_versioned == 'no'){
    if ($war_version != undef) {
      notify{"war version parameter setted, but war versioned parameter is set to yes. Ignoring war version.":}
    }
  }
  
  if ($deploy_path == undef){
    notify{'Deploy path not specified, setting default deploy folder /webapps/':}
    $defined_deploy_path =$default_deploy
  } else {
    $defined_deploy_path = $deploy_path
  } 
  
  if ($installdir == undef){
    notify{'Install folder not specified, setting default install folder /opt/':}
    $defined_installdir ='/opt/'
  } else {
    $defined_installdir = $installdir
  }
 
  if ($tmpdir == undef){
    notify{'Temp folder not specified, setting default install folder /tmp/':}
    $defined_tmpdir ='/tmp/'
  } else {
    $defined_tmpdir = $tmpdir
  }
  
  if (($defined_deploy_path == $default_deploy) and ($context != undef)){
    notify{'deploy path is default, context will not be considered':}
  }
  
  if (($defined_deploy_path != $default_deploy) and ($context == undef)){
    fail('context parameter must be set if deploy path is different from /webapps/')
  }
  
  if ($defined_deploy_path == $default_deploy){
	  if ($defined_war_versioned == 'no'){  
		  file { "${defined_tmpdir}${war_name}${extension}":
		          ensure => present,
		          source => "puppet:///modules/tomcat/${war_name}${extension}",
		          alias => "tmp_war" }
		          
		  exec { 'move_war': 
		          command => "mv ${defined_tmpdir}${war_name}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
		          require => File[ tmp_war ] ,
		          unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
		          alias => "move_war" }
		          
		  exec { 'clean_war': 
		          command => "rm -rf ${defined_tmpdir}${war_name}${extension}",
		          require => Exec[move_war],
		          logoutput => "false" }
		          
		  } elsif ($defined_war_versioned == 'yes'){
		    
		  file { "${defined_tmpdir}${war_name}-${war_version}${extension}":
	            ensure => present,
	            source => "puppet:///modules/tomcat/${war_name}-${war_version}${extension}",
	            alias => "tmp_war" }
	            
	    exec { 'move_war': 
	            command => "mv ${defined_tmpdir}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
	            require => File[ tmp_war ] ,
	            unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
	            alias => "move_war" }
	            
	    exec { 'clean_war': 
	            command => "rm -rf ${defined_tmpdir}${war_name}-${war_version}${extension}",
	            require => Exec[move_war],
	            logoutput => "false" }
		  }
	  } else {

	      exec { 'create_alternative_deploy_path': 
            command => "mkdir ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
            unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
            alias => "alternative_deploy_path" }
	    
        exec { 'create_app_context_path': 
            command => "mkdir -p ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}",
            alias => "app_context_path" }	    
	    
	      if ($defined_war_versioned == 'no'){  
	      file { "${defined_tmpdir}${war_name}${extension}":
	              ensure => present,
	              source => "puppet:///modules/tomcat/${war_name}${extension}",
	              require => Exec[alternative_deploy_path],
	              alias => "tmp_war" }
	              
	      exec { 'move_war': 
	              command => "mv ${defined_tmpdir}${war_name}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
	              require => [File[ tmp_war ] , Exec[alternative_deploy_path] ],
	              unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
	              alias => "move_war" }
	              
	     file { "app_context_xml":
            path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${war_name}.xml",
            owner   => 'root',
            group   => 'root',
            require => [ Exec[move_war], Exec[app_context_path] ],
            mode    => '0644',
            content => template('tomcat/appcontext.erb') }  
	              
	      exec { 'clean_war': 
	              command => "rm -rf ${defined_tmpdir}${war_name}${extension}",
	              require => Exec[move_war],
	              logoutput => "false" }
	              
	      } elsif ($defined_war_versioned == 'yes'){
	        
	      file { "${defined_tmpdir}${war_name}-${war_version}${extension}":
	              ensure => present,
	              source => "puppet:///modules/tomcat/${war_name}-${war_version}${extension}",
	              alias => "tmp_war" }
	              
	      exec { 'move_war': 
	              command => "mv ${defined_tmpdir}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
	              require => [File[ tmp_war ] , Exec[alternative_deploy_path] ],
	              unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
	              alias => "move_war" }
	              
	      exec { 'clean_war': 
	              command => "rm -rf ${defined_tmpdir}${war_name}-${war_version}${extension}",
	              require => Exec[move_war],
	              logoutput => "false" }
		      }
		    }
		 }