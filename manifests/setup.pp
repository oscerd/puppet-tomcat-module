define tomcat::setup (
  $family = undef,
  $update_version = undef,
  $extension = undef,
  $mode = undef,
  $tmpdir = undef,
  $installdir = undef
  ) { 
    
  # Validate parameters presence 
  
  if ($family == undef) {
    fail('family parameter must be set')
  }
  
  if ($update_version == undef) {
    fail('update version parameter must be set')
  }
  
  if ($extension == undef) {
    fail('Extension parameter must be set')
  }
  
  if ($mode == undef) {
    fail('mode parameter must be set')
  }
  
  # Validate parameters  
  
  if (($family != '6') and ($family != '7') and ($family != '8')) {
    fail('family parameter must be between "6" and "8" included')
  }

  if (($extension != ".tar.gz") and ($extension != ".zip")) {
    fail('Extension parameter must be ".tar.gz" or "zip"')
  }
  
  if (($mode != 'web') and ($mode != 'local')) {
    fail('mode parameter must have value "local" or "web"')
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
  
  $tomcat = "apache-tomcat"
  
  if ($mode == "local"){
  file { "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}":
		      ensure => present,
		      source => "puppet:///modules/tomcat/${tomcat}-${family}.0.${update_version}${extension}" }
  
    exec { 'extract_tomcat': 
          command => "tar -xzvf ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} -C ${defined_tmpdir}",
          require => [ File[ "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}"], 
                       Package['tar'] ], 
          alias => extract_tomcat } 
  }
  elsif ($mode == "web"){
    
  $source = "http://apache.fastbull.org/tomcat/tomcat-7/v7.0.55/bin/${tomcat}-${family}.0.${update_version}${extension}"

  exec { 'retrieve_tomcat': 
          command => "wget -q ${source} -P ${defined_tmpdir}",
          unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/",
          timeout => 1000 }    
          
    exec { 'extract_tomcat': 
          command => "tar -xzvf ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} -C ${defined_tmpdir}",
          require => [ Exec[ 'retrieve_tomcat'], 
                       Package['tar'] ], 
          alias => extract_tomcat } 
  } 
                     
  file { "$defined_installdir":
		      ensure => directory,
		      mode => '755',
		      owner => 'root', 
		      alias => tomcat_home }
  
  exec { 'move_tomcat': 
          command => "mv ${defined_tmpdir}${tomcat}-${family}.0.${update_version}/ ${defined_installdir}",
          require => [ File[ tomcat_home ], 
                       Exec[ extract_tomcat ] ],
                    unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/" }
}