# tomcat::setup defines the deploy stage of Tomcat installation
define tomcat::deploy (
  $war_name = undef,
  $deploy_path = undef,
  $family = undef,
  $update_version = undef,
  $installdir = undef
  ) { 
  
  $extension = ".war"
  $tomcat = "apache-tomcat"

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
  
  if ($deploy_path == undef){
    notify{'Deploy path not specified, setting default deploy folder /webapps/':}
    $defined_installdir ='/webapps/'
  } else {
    $defined_deploy_path = $deploy_path
  } 
  
  if ($installdir == undef){
    notify{'Install folder not specified, setting default install folder /opt/':}
    $defined_installdir ='/opt/'
  } else {
    $defined_installdir = $installdir
  }
    
  file { "${installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}":
          ensure => present,
          source => "puppet:///modules/tomcat/${war_name}${extension}",
          alias => "deploying_war" }
  
    exec { "make_executable":
          command => "chmod +x ${installdir}${tomcat}-${family}.0.${update_version}/bin/*.sh",
          require => File[deploying_war],
          alias => "executable" } 
         
	exec { "start_tomcat":
	        command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
          require => [Exec[executable], File[deploying_war]] }      
  }
  
  define arrayDebug {
        notify { "Item ${name}": }
  }